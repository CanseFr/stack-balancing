## Scalling horizontal

Nous allons ici mettre en place un reverse proxy tres simpel a l'aide de Nginx Proxy Manager pour deployer des container de type NestJs(Typescript).

## Introduction

**Scalling horizontal** : \
Le "Scaling horizontal" (mise à l'échelle horizontale) est une technique de gestion de la charge dans laquelle de nouvelles instances ou serveurs sont ajoutés à un système ou une application existante afin de répartir la charge de manière équilibrée. Cette approche vise à améliorer les performances et la disponibilité en permettant au système de gérer un plus grand nombre de requêtes ou d'utilisateurs tout en maintenant une qualité de service élevée. Elle est souvent utilisée dans les environnements informatiques cloud et les applications Web pour garantir une extensibilité efficace.

**Scalling vertical** : \
Le "Scaling vertical" (mise à l'échelle verticale) est une technique de gestion de la charge dans laquelle les ressources d'un serveur ou d'une instance existante sont augmentées, généralement en ajoutant plus de puissance de calcul, de mémoire ou d'autres ressources matérielles. Contrairement au "Scaling horizontal" qui consiste à ajouter davantage de serveurs ou d'instances, le scaling vertical implique d'optimiser les ressources d'une seule machine pour améliorer ses performances. Cela peut être utile pour des charges de travail spécifiques qui nécessitent plus de ressources, mais il peut atteindre une limite en termes de capacité matérielle disponible sur une seule machine.

Il est important de placer le .env de le gitignore pour pas publier nos informations personnel, !
Par contre il est important de ne pas le placer dans le dockerignore car docker en a besoin etant donné qu'on utilise ldes variabel d'env dans le docker-compose.

## Mise en place de l'app

L'application en place se limite à renvoyer un hello word sur l'URL de base de l'application web.

## Docker File

```Dockerfile
FROM node:18

WORKDIR /app/nest

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build

CMD [ "npm", "run", "start:dev" ]
```

## Docker Compose

Ici nous allons desactiver les parametre en rapport avec le ssl et le https pour ne pas rallonger ce tutoriel.

```yaml
version: '3.8'

services:
  nestjs-app:
    build: . # Chemin vers le rÃ©pertoire contenant le Dockerfile de nestjs

  nginx-proxy-manager:
    image: 'jc21/nginx-proxy-manager'
    restart: unless-stopped
    depends_on:
      - db-proxy
    ports:
      - '82:80' # Port HTTP
      - '81:81' # Interface d'administration NPM
    environment:
      DB_MYSQL_HOST: db-proxy
      DB_MYSQL_PORT: 3306
      DB_MYSQL_USER: ${MYSQL_USER}
      DB_MYSQL_PASSWORD: ${MYSQL_PASSWORD}
      DB_MYSQL_NAME: ${MYSQL_DATABASE}
      DISABLE_HTTPS: 'true' # A desactiver en production
      #DISABLE_IPV6: 'true' # A activer pour certains conteneurs
    volumes:
      - proxy-data:/data
      - proxy-letsencrypt:/etc/letsencrypt

  db-proxy:
    image: 'jc21/mariadb-aria'
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    volumes:
      - db-proxy-data:/var/lib/mysql

volumes:
  proxy-data:
  proxy-letsencrypt:
  db-proxy-data:
```

## .env

Ici nous allons placer nos variable d'environement necessaire et inscrite dans notre fichier docker-compose.yaml

```env
MYSQL_ROOT_PASSWORD=proxy
MYSQL_DATABASE=proxy
MYSQL_USER=proxy
MYSQL_PASSWORD=proxy
```

## .gitignore

Penser a placer ce fichier dans le point .gitignore pour de na reveller les données sensible

```gitignore
.env
```


## Lancer l'app

Une fois l'app en place, lancer le container en local :

```zsh
docker-compose up
```
Puis consulter l'url :

```url
http://localhost:81/login
```

**Connectez vous :**

Email:    admin@example.com \
Password: changeme

## Proxy Setup

CLiquer sur  'Proxy host' puis sur  'Add Proxy Host'.

Dans cet input saisissez l'adresse ip de l'host de la machine. Attention a ne pas mettre localhost car nginx vas l'interpretter comme "lui meme".
ipconfig ou ifconfig pour recuperer son adresse ip

```zsh
ipconfig (Windows : Recuperer adresse ip Eth0)
ifconfig (Linux : Recuperer adresse ip en0)
```

Ensuite je vais preciser dans forward hostname ip le nom de domaine interne de l'ap *nestjs-app* precisé dans le fichier *docker-compose.yaml*.

```yaml
services:
  nestjs-app:
    build: . # Chemin vers le rÃ©pertoire contenant le Dockerfile de Flask
```

Puis precisr le port de NestJs que l'on a inscrit precedement dans le Dockerfile.

```yaml
# Expose le port sur lequel l'application s'exécutera
EXPOSE 3000
```

![img.png](assets/img.png)

Cliquer sur Valider.

Puis aller dans un navigateur puis consulter l'adresse ip inscrit preceddement.

![img_1.png](assets/img_1.png)

## Créations multiple de containers

Maintenant nous allons ouvrir un nouveau terminal puis executer la commande suivante :

```zsh
docker-compose up -d --scale nestjs-app=3
```

Trois nouvelles instance vont etre crée, vous pouvez constater le resultat en regardant l'interface de docker ou en utilisant le terminal.







# Flask-Reverse-Proxy
