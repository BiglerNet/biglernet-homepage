# Build stage. Runs on the build host's native arch (--platform=$BUILDPLATFORM)
# even when cross-building for arm64: `dotnet publish` with no -r/--arch produces
# framework-dependent IL that the target-arch runtime image below can run
# unmodified, so there's nothing here that actually needs emulation.
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY src/BiglerNet.Website/BiglerNet.Website.csproj src/BiglerNet.Website/
RUN dotnet restore src/BiglerNet.Website/BiglerNet.Website.csproj

COPY src/BiglerNet.Website/ src/BiglerNet.Website/
RUN dotnet publish src/BiglerNet.Website/BiglerNet.Website.csproj \
    -c Release \
    -o /app/publish \
    --no-restore

# Runtime stage - use ASP.NET Core to serve static files
FROM mcr.microsoft.com/dotnet/aspnet:10.0-alpine
WORKDIR /app
COPY --from=build /app/publish .

EXPOSE 8080
ENTRYPOINT ["dotnet", "BiglerNet.Website.dll"]
