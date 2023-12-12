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
1. Iniciar Minikube (Debe tener Docker ejecutando):
```shell
$ minikube start
$ minikube dashboard
```
2. Instalación del Chart de Argo CD
```shell
$ kubectl create ns argo-cd
$ helm repo add argo https://argoproj.github.io/argo-helm
$ helm install argocd argo/argo-cd -n argo-cd
```
3. Ingresar a la siguiente URL: 
```shell
http://localhost:8080
$ kubectl port-forward service/argocd-server -n argo-cd 8080:443
```
4. El user por defecto es admin y el password se genera automático y se obtiene con el siguiente comando:
```shell
$ kubectl -n argo-cd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```
Generar Password:
![Screenshot](./assets/generate_password.png)

Autenticación:
![Screenshot](./assets/autentication.png)

5. En la carpeta Dev crear dos archivos
- api-dotnet-basicauth-deployment.yaml
- api-dotnet-basicauth-service.yaml

api-dotnet-basicauth-deployment.yaml
```shell
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-dotnet-basicauth-deployment
spec:
  replicas: 2
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

api-dotnet-basicauth-service.yaml
```shell
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-dotnet-basicauth-deployment
spec:
  replicas: 2
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

```shell
$ kubectl apply -f application.yaml
```
Evidecia del correcto funcionamiento:

ArgoCD:
![Screenshot](./assets/argo_cd_1.png)

Minikube Namespace:
![Screenshot](./assets/minkube.png)