# deploy-ludo.ps1
# Script para limpiar, instalar, construir y hacer push a GitHub

# 🔹 Configuración
$branch = "main"
$commitMsg = "Deploy automático: limpieza, build y push"

Write-Host "Iniciando deploy automático de LUDO..."

# 1️ Cerrar procesos node si existen
Stop-Process -Name node -Force -ErrorAction SilentlyContinue
Write-Host "Procesos Node cerrados (si existían)"

# 2️ Limpiar node_modules y package-lock.json
if (Test-Path .\node_modules) {
    Remove-Item -Recurse -Force .\node_modules
    Write-Host " node_modules eliminado"
} else {
    Write-Host " node_modules no existe o ya estaba vacío"
}

if (Test-Path .\package-lock.json) {
    Remove-Item -Force .\package-lock.json
    Write-Host "package-lock.json eliminado"
} else {
    Write-Host "package-lock.json no existe"
}

# 3️ Limpiar cache de npm
npm cache clean --force
Write-Host " Cache de npm limpiada"

# 4️ Instalar dependencias correctas
Write-Host " Instalando dependencias con legacy-peer-deps..."
npm install --legacy-peer-deps

# 5️ Build de producción
Write-Host " Generando build de producción..."
npm run build

# 6️ Commit y push a GitHub
git add .
git commit -m "$commitMsg"
git push origin $branch
Write-Host " Commit y push completados"

# 7️ Preview local (opcional)
Write-Host " Preview local disponible en http://localhost:4173/"
Write-Host "Para exponer en tu red: npx vite preview --host"

Write-Host " Deploy completado. Revisa Vercel para confirmar build exitoso."