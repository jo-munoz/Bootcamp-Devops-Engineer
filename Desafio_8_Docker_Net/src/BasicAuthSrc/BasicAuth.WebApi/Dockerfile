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

# Construir la imagen:
# docker build -t basic-auth-api:v0.0.1 .

# Ejecutar un contenedor a partir de la imagen:
# docker run -d --name basic-auth-api \
# -p 8080:80 \
# basic-auth-api:v0.0.1