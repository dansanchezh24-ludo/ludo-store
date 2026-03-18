# deploy-ludo-final.ps1
# Deploy definitivo de LUDO para Windows + Vercel
# Automatiza limpieza, corrección de package.json, instalación, build, push y deploy

$branch = "main"
$commitMsg = "Deploy automático final: limpieza, build y deploy en Vercel"

Write-Host "Iniciando deploy definitivo de LUDO..."

# 1. Cerrar procesos Node
$nodeProcesses = Get-Process -Name node -ErrorAction SilentlyContinue
if ($nodeProcesses) {
    $nodeProcesses | Stop-Process -Force
    Write-Host "Procesos Node cerrados"
} else { Write-Host "No hay procesos Node activos" }

# 2. Eliminar node_modules y package-lock.json
if (Test-Path .\node_modules) {
    try {
        Remove-Item -Recurse -Force .\node_modules -ErrorAction Stop
        Write-Host "node_modules eliminado"
    } catch {
        Write-Host "Archivos bloqueados detectados, forzando eliminación..."
        Get-ChildItem .\node_modules -Recurse | ForEach-Object { $_.IsReadOnly = $false }
        Remove-Item -Recurse -Force .\node_modules
    }
} else { Write-Host "node_modules no existe" }

if (Test-Path .\package-lock.json) {
    Remove-Item -Force .\package-lock.json
    Write-Host "package-lock.json eliminado"
} else { Write-Host "package-lock.json no existe" }

# 3. Limpiar cache de npm
npm cache clean --force
Write-Host "Cache de npm limpiada"

# 4. Corregir package.json automáticamente
$packageJsonPath = ".\package.json"
if (Test-Path $packageJsonPath) {
    $json = Get-Content $packageJsonPath -Raw | ConvertFrom-Json

    # Engines correctos
    $json.engines.node = "24.x"
    $json.engines.npm = "10.x"

    # Forzar versión compatible de Vite
    $viteVersion = "8.0.0"
    if ($json.devDependencies.vite) { $json.devDependencies.vite = "^$viteVersion" } 
    else { $json.devDependencies += @{ vite = "^$viteVersion" } }

    $json | ConvertTo-Json -Depth 10 | Set-Content $packageJsonPath
    Write-Host "package.json corregido: Node 24.x, npm 10.x, Vite $viteVersion"
} else {
    Write-Host "No se encontró package.json"
    exit 1
}

# 5. Instalar dependencias robustamente
Write-Host "Instalando dependencias..."
try {
    npm install --legacy-peer-deps
} catch {
    Write-Host "Instalación falló, intentando con --force..."
    npm install --force
}

# 6. Build de producción con fallback
Write-Host "Generando build de producción..."
try {
    npm run build
} catch {
    Write-Host "Build falló con npm, intentando con node directo..."
    node node_modules/vite/bin/vite.js build
}

# 7. Commit y push automático a GitHub
git add .
git commit -m "$commitMsg"
git push origin $branch
Write-Host "Commit y push completados"

# 8. Deploy directo a Vercel
Write-Host "Iniciando deploy en Vercel..."
try {
    npx vercel --prod --confirm
    Write-Host "Deploy en Vercel completado"
} catch {
    Write-Host "Deploy falló. Revisa configuración de Vercel"
}

# 9. Preview local opcional
Write-Host "Preview local disponible: http://localhost:4173/"
Write-Host "Para exponer en red: npx vite preview --host"

Write-Host "Deploy definitivo completado."