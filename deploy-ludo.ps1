# deploy-ludo.ps1
# Script automático de build y deploy para LUDO
# ⚠️ Ejecutar en PowerShell con permisos de administrador si hay archivos bloqueados

Write-Host "🚀 Iniciando deploy automático de LUDO..."

# ---------------------------
# 1️⃣ Cerrar procesos Node activos (si los hay)
# ---------------------------
Get-Process node -ErrorAction SilentlyContinue | ForEach-Object {
    Stop-Process -Id $_.Id -Force
}
Write-Host "✅ Procesos Node cerrados (si existían)"

# ---------------------------
# 2️⃣ Limpiar dependencias antiguas
# ---------------------------
Try {
    Remove-Item -Recurse -Force .\node_modules -ErrorAction Stop
    Write-Host "✅ node_modules eliminado"
} Catch {
    Write-Host " node_modules no se pudo eliminar completamente o ya estaba vacío"
}

Try {
    Remove-Item -Force .\package-lock.json -ErrorAction Stop
    Write-Host " package-lock.json eliminado"
} Catch {
    Write-Host " package-lock.json no existe"
}

# ---------------------------
# 3️⃣ Instalar dependencias
# ---------------------------
Write-Host "Instalando dependencias con legacy-peer-deps..."
npm install --legacy-peer-deps

# ---------------------------
# 4️⃣ Generar build de producción
# ---------------------------
Write-Host " Generando build de producción..."
npx vite build
Write-Host " Build completada. Carpeta 'dist' lista para Vercel."

# ---------------------------
# 5️⃣ Commit y push automático a GitHub
# ---------------------------
# Asegúrate de que tu repo ya tenga origin configurado y credenciales guardadas
Write-Host " Commit y push automático a GitHub..."
git add .
$commitMessage = "Deploy automático - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
git commit -m "$commitMessage"
git push origin main
Write-Host " Commit y push completados"

# ---------------------------
# 6️⃣ Preview local opcional
# ---------------------------
Write-Host "Preview local (opcional) en http://localhost:4173/"
Write-Host "Para exponer en tu red: npx vite preview --host"
npx vite preview

Write-Host "🎉 Deploy terminado. Vercel detectará automáticamente los cambios y hará el deploy."