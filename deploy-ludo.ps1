# deploy-ludo.ps1 - Script completo para Windows PowerShell
# Asegúrate de haber configurado tu repositorio Git remoto correctamente

# Configuración: mensaje de commit
$commitMessage = "Deploy automatico - build lista para Vercel"

Write-Host "Limpiando dependencias antiguas..."
Remove-Item -Recurse -Force .\node_modules -ErrorAction SilentlyContinue
Remove-Item -Force .\package-lock.json -ErrorAction SilentlyContinue

Write-Host "Instalando dependencias con legacy-peer-deps..."
npm install --legacy-peer-deps

Write-Host "Generando build de producción..."
npm run build

Write-Host "Levantando preview local en http://localhost:4173/ (opcional)..."
Start-Process "cmd" "/c npm run preview"

Write-Host "Haciendo commit y push automático a GitHub..."
git add .
git commit -m "$commitMessage"
git push origin main

Write-Host " Todo listo! Build subida a GitHub y lista para deploy en Vercel."