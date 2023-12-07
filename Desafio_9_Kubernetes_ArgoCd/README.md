# Implementación de Minikube y Argo CD con Kubernetes

## Objetivo:
1. Instalar argoCD.
2. Crear una aplicación en argoCD.
3. Desplegar un chart de helm con argoCD.

## Requisitos:
1. Tener instalado minikube.
2. Tener instalado kubectl.
3. Tener instalado helm.

## Desarrollo:
1. Instalación del Chart de Argo CD
```shell
$ kubectl create ns argo-cd
$ helm repo add argo https://argoproj.github.io/argo-helm
$ helm install argocd argo/argo-cd -n argo-cd
```
2. argoCD port-forward.
```bash
kubectl port-forward service/argocd-server -n argo-cd 8080:443
```
3. Obtener la password del usuario `admin`.
   Para equipos con OS Windows necesitaran instalar el programa base64, pueden hacerlo desde chocolatey.
   [link](https://community.chocolatey.org/packages/base64)

   ```bash
   kubectl -n argo-cd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   ```
4. Crear una aplicación en argoCD.
```bash
cd Clase41/argocd
kubectl apply -f applicacion.yaml
```
Ahora que tenemos argoCD instalado y una aplicación creada, vamos a trabajar desde la UI.

1. Clonar el repositorio:
    ```shell
    git clone https://github.com/jo-munoz/Bootcamp-Devops-Engineer
    cd Bootcamp-Devops-Engineer/Desafio_8_Docker_Net
    ```

2. Construir la imagen:
    ```shell
    $ cd /src/BasicAuth/BasicAuth.WebApi/
    $ docker build -t dockerapp:v0.0.1 .
    $ docker images
    ```

    Nota: una vez realizado lo anterior se va ver en la aplicación Docker en el menu "Images":

    ![Screenshot](./assets/docker_images.png)

3. Ejecutar un contenedor a partir de la imagen:

    Archivo Dockerfile:

    ```bash
    FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
    WORKDIR /app
    EXPOSE 80
    EXPOSE 443

    FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
    WORKDIR /src
    COPY ["BasicAuth.WebApi.csproj", "BasicAuth.WebApi/"]
    RUN dotnet restore "BasicAuth.WebApi/BasicAuth.WebApi.csproj"
    COPY . BasicAuth.WebApi
    WORKDIR "/src/BasicAuth.WebApi"
    RUN dotnet build "BasicAuth.WebApi.csproj" -c Release -o /app/build

    FROM build AS publish
    RUN dotnet publish "BasicAuth.WebApi.csproj" -c Release -o /app/publish /p:UseAppHost=false

    FROM base AS final
    WORKDIR /app
    COPY --from=publish /app/publish .
    ENTRYPOINT ["dotnet", "BasicAuth.WebApi.dll"]
    ```
    Comando en Git Bash:
    ```shell
    $ docker run -d --name basic-auth-api \
    -e "ASPNETCORE_ENVIRONMENT=Development" \
    -p 8080:80 \
    basic-auth-api:v0.0.1
    ```

    También  se puede ejecutar un contenedor a partir de un Docker Compose:

* Archivo docker-compose.yml:

    ```bash
    version: '3'
    services:
    basic-auth-api:
        build: .
        container_name: basic-auth-api
        ports:
        - 8080:80
        deploy:
        restart_policy:
            condition: on-failure
            delay: 3s
            max_attempts: 5
            window: 60s
    ```

    Comando:

      $ cd /src/BasicAuth/BasicAuth.WebApi/
      $ docker compose up -d

    Nota: una vez realizado lo anterior se va ver en la aplicación Docker en el menu "Containers":    

    ![Screenshot](./assets/docker_containers.png)

* En este punto ya se puede acceder a la url: http://localhost:8080/swagger/index.html desde un navegador

    ![Screenshot](./assets/docker_swagger.png)

* Confirmar que este funcional la API:

    ![Screenshot](./assets/docker_swagger_test.png)

# Implementación de Pipeline de CI/CD en GitHub Actions

1. Ingresar al repositorio en GitHub (para este ejemplo voy hacerlo con un repositorio de prueba) e instalar el Docker Container:

    ![Screenshot](./assets/docker_github_actions.png)

2. Ingresar a la Url: https://hub.docker.com para registrarse y crear un repositorio:

    ![Screenshot](./assets/docker_hub.png)

3. Ingresar a Account Settings / Security y generar un token y guardarlo en un archivo que mas adelante se va necesitar:

    ![Screenshot](./assets/docker_hub_tokens.png)

4. Volver al repositorio en GitHub y crear usuario y contraseña:

    ![Screenshot](./assets/docker_github_credentials.png)

    * Archivo .github\workflows:

    ```bash
    name: DockerApp DotNet Build and Publish

    on:
    workflow_dispatch:
    push:
        branches:
        - main    
        paths: 
        - 'Desafio_8_Docker_Net/src/BasicAuthSrc/BasicAuth.WebApi/*' 
        tags:
        - 'v*'

    jobs:
    build-and-publish:
        runs-on: ubuntu-latest

        steps:
        - name: Checkout code
            uses: actions/checkout@v2

        - name: Set up Docker Buildx
            uses: docker/setup-buildx-action@v1

        - name: Login to Docker Hub
            uses: docker/login-action@v1
            with:
            username: ${{ secrets.DOCKER_USERNAME }}
            password: ${{ secrets.DOCKER_PASSWORD }}

        - name: Extract metadata (tags, labels) for Docker
            id: meta
            uses: docker/metadata-action@v5
            with:
            images: devjmunoz/api-dotnet-basicauth
            flavor: latest=true
            tags: |
                type=semver,pattern={{version}}
                type=semver,pattern={{major}}.{{minor}}
                type=sha

        - name: Build and push Docker image
            uses: docker/build-push-action@v2
            with:
            context: ${{ github.workspace }}/Desafio_8_Docker_Net/src/BasicAuthSrc/BasicAuth.WebApi
            push: true          
            tags: ${{ steps.meta.outputs.tags }}
            labels: ${{ steps.meta.outputs.labels }}
    ```

5. Al hacer un commit se suben los cambios en Docker Hub:

    ![Screenshot](./assets/docker_hub_commits.png)

# Implementación de Kubernetes y Minikube

1. Descargar, instalar e iniciar el servicio de minikube, url de descarga: https://minikube.sigs.k8s.io/docs/start

    ```shell
    $ minikube start
    $ minikube dashboard
    ```

    ![Screenshot](./assets/kubernetes_start.png)

    ![Screenshot](./assets/kubernetes_dashboard.png)

2. Aplicar los cambios en el archivo api-dotnet-basicauth-deployment.yaml:

    ```bash
    apiVersion: apps/v1
    kind: Deployment
    metadata:
    name: api-dotnet-basicauth-deployment
    spec:
    replicas:
    selector:
        matchLabels:
        app: api-dotnet-basicauth
    template:
        metadata:
        labels:
            app: api-dotnet-basicauth
        spec:
        containers:
            - name: api-dotnet-basicauth
            image: devjmunoz/api-dotnet-basicauth
            env:
                - name: ASPNETCORE_ENVIRONMENT
                value: Development
            ports:
                - containerPort: 80
    ```

    Comando:    
    ```shell
    $ cd /kubernetes/deployments
    $ kubectl apply -f api-dotnet-basicauth-deployment.yaml
    ```
    
    ![Screenshot](./assets/kubernetes_services.png)

3. Aplicar los cambios en el archivo api-dotnet-basicauth-service.yaml:

    ```bash
    apiVersion: v1
    kind: Service
    metadata:
    name: api-dotnet-basicauth-service
    spec:
    selector:
        app: api-dotnet-basicauth
    ports:
        - protocol: TCP
        port: 8080
        targetPort: 80
    type: NodePort
    ```
    
    Comando:
    ```shell
    $ cd /kubernetes/services
    $ kubectl apply -f api-dotnet-basicauth-service.yaml
    ```
    
    ![Screenshot](./assets/kubernetes_deployments.png)
    
4. Para saber cual es la url:
    ```shell
    $ minikube service dockerapp-service --url
    ```

    ![Screenshot](./assets/kubernetes_get_url.png)
    
    ![Screenshot](./assets/kubernetes_test.png)    