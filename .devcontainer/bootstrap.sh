#!/bin/bash

# Crear NestJS Gateway
echo "Verificando y creando proyecto nestjs-gateway..."
if [ ! -f "./nestjs-gateway/package.json" ]; then
  cd nestjs-gateway
  npx @nestjs/cli new . --package-manager=npm --skip-git --skip-install
  echo "Proyecto nestjs-gateway creado."

  touch .gitignore
  touch .dockerignore
  echo "Archivos .gitignore y .dockerignore creados automáticamente."

  cat <<EOL > start.sh
#!/bin/bash

echo "Iniciando proyecto NestJS Gateway..."
npm install
npm run start:dev
EOL

  chmod +x start.sh
  echo "start.sh creado para NestJS Gateway."
  cd ..
else
  echo "nestjs-gateway ya existe."
fi

# Crear FastAPI ML API
echo "Verificando y creando proyecto fastapi-ml-api..."
if [ ! -d "./fastapi-ml-api" ]; then
  mkdir fastapi-ml-api
  cd fastapi-ml-api

  cat <<EOL > main.py
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "FastAPI ML API Running"}
EOL

  echo -e "fastapi\nuvicorn" > requirements.txt

  # start.sh para correr localmente sin Docker
  cat <<EOL > start.sh
#!/bin/bash

echo "Iniciando FastAPI ML API localmente..."
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
EOL

  chmod +x start.sh

  cat <<EOL > Dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENTRYPOINT ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port 8000 --reload"]
EOL

  echo "Proyecto fastapi-ml-api creado con start.sh y Dockerfile listos."
  cd ..
else
  echo "fastapi-ml-api ya existe."
fi


# Crear Next.js Web Client
echo "Verificando y creando proyecto nextjs-web-client..."
if [ ! -d "./client" ]; then
  npx create-next-app@latest client
  echo "Proyecto client creado."

  cd client

  # Crear archivos adicionales si quieres
  touch .dockerignore
  echo "node_modules\n.next\nout" > .dockerignore

  # start.sh para facilitar arranque local
  cat <<EOL > start.sh
#!/bin/bash

echo "Iniciando Next.js Web Client..."
npm install
npm run dev
EOL

  chmod +x start.sh
  echo "start.sh creado para Next.js Web Client."

  cd ..
else
  echo "nextjs-web-client ya existe."
fi


# Crear proyecto admin con Vite
echo "Verificando y creando proyecto admin (Vite + React + TS)..."
if [ ! -d "./admin" ]; then
  npm create vite@latest admin -- --template react-ts
  echo "Proyecto admin creado."

  cd admin

  # Instalar dependencias iniciales del proyecto
  echo "Instalando dependencias del proyecto admin..."
  npm install

  echo "Instalando TailwindCSS y dependencias..."
  npm install -D tailwindcss postcss autoprefixer @tailwindcss/forms @tailwindcss/typography

  # Inicializar configuración de Tailwind
  npx tailwindcss init -p

  # Modificar contenido en tailwind.config.js
  sed -i "s/content: \[\]/content: \['.\/index.html', '.\/src\/*\*\/\*.{js,ts,jsx,tsx}'\]/" tailwind.config.js

  # Crear start.sh
  cat <<EOL > start.sh
#!/bin/bash

echo "Iniciando Admin Vite React..."
npm run dev
EOL

  chmod +x start.sh
  echo "start.sh creado para admin."

  cd ..
else
  echo "admin ya existe."
fi
