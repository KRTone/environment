FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . .
RUN dotnet restore DotNetApp.sln
RUN dotnet publish src/DotNetApp/DotNetApp.csproj -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:8080
COPY --from=build /app/publish .
EXPOSE 8080
ENTRYPOINT ["dotnet", "DotNetApp.dll"]
