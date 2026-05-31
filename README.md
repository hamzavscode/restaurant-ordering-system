# 🍽️ Restaurant API - Projet Backend Kotlin / Spring Boot

## 📝 Description
Cette application est une **API REST** développée en **Kotlin** avec **Spring Boot** pour gérer les éléments d’un restaurant :
les plats, les boissons, les desserts, les commandes et les clients.  
Elle permet d’ajouter, modifier, supprimer et consulter les informations via des endpoints REST.

---

## 🛠️ Technologies Utilisées
- **Langage :** Kotlin
- **Framework :** Spring Boot 3
- **Base de données :** MySQL
- **Build Tool :** Gradle
- **ORM :** Spring Data JPA / Hibernate

---

## 📊 Diagramme UML
![Diagramme UML des entités - Restaurant API](uml_diagram.png.jpg)

---

## 🗃️ Structure de la Base de Données
- **Client :** représente les clients du restaurant
- **Commande :** relie un client à plusieurs éléments du menu
- **ElementMenu :** classe mère (abstraite) des éléments du menu
- **PlatPrincipal :** représente les plats principaux
- **Boisson :** représente les boissons disponibles
- **Dessert :** représente les desserts proposés par le restaurant

---

## 🚀 Installation et Exécution

### 🔧 Prérequis
- JDK 17+
- MySQL installé
- Gradle

---

### 🪜 Étapes d'installation

#### 1️⃣ Cloner le repository
```bash
git clone https://github.com/hamzavscode/restaurant-ordering-system.git
```

#### 2️⃣ Créer la base de données
```sql
CREATE DATABASE restaurant_db;
```

#### 3️⃣ Configurer application.properties
Modifiez le fichier `src/main/resources/application.properties` si nécessaire :
```properties
spring.application.name=RestaurantApi
spring.datasource.url=jdbc:mysql://localhost:3306/restaurant_db
spring.datasource.username=root
spring.datasource.password=
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.jpa.hibernate.ddl-auto=update
spring.jpa.database-platform=org.hibernate.dialect.MySQL8Dialect
spring.jpa.show-sql=true
```

#### 4️⃣ Lancer l’application
```bash
./gradlew bootRun
```

---

## 📡 Endpoints Disponibles

### 👤 Client
- `GET /api/clients` → Récupérer tous les clients
- `GET /api/clients/{id}` → Récupérer un client par ID
- `POST /api/clients/register` → Créer un nouveau client
- `POST /api/clients/login` → Authentifier un client
- `PUT /api/clients/{id}` → Mettre à jour un client
- `DELETE /api/clients/{id}` → Supprimer un client

### 🍔 Plat Principal
- `GET /api/plats` → Récupérer tous les plats
- `GET /api/plats/{id}` → Récupérer un plat par ID
- `POST /api/plats` → Créer un plat
- `PUT /api/plats/{id}` → Mettre à jour un plat
- `DELETE /api/plats/{id}` → Supprimer un plat

### 🍰 Dessert
- `GET /api/desserts` → Récupérer tous les desserts
- `GET /api/desserts/{id}` → Récupérer un dessert par ID
- `POST /api/desserts` → Créer un dessert
- `PUT /api/desserts/{id}` → Mettre à jour un dessert
- `DELETE /api/desserts/{id}` → Supprimer un dessert

### 🥤 Boisson
- `GET /api/boissons` → Récupérer toutes les boissons
- `GET /api/boissons/{id}` → Récupérer une boisson par ID
- `POST /api/boissons` → Créer une boisson
- `PUT /api/boissons/{id}` → Mettre à jour une boisson
- `DELETE /api/boissons/{id}` → Supprimer une boisson

### 📦 Commande
- `GET /api/commandes` → Récupérer toutes les commandes
- `GET /api/commandes/{id}` → Récupérer une commande par ID
- `POST /api/commandes` → Créer une commande
- `PUT /api/commandes/{id}` → Mettre à jour une commande (ex: annuler)
- `DELETE /api/commandes/{id}` → Supprimer une commande

---

## ✨ Améliorations Techniques Intégrées
- Validation des données avec `@Valid`, `@NotNull`, `@NotBlank`, etc.
- Gestion centralisée des exceptions (`@ControllerAdvice`).
- Utilisation des DTOs pour séparer la couche de présentation.
- Architecture multi-couches (Controller → Service → Repository).
- Application mobile compagnon (Flutter) avec support hors-ligne (SQLite).

---

## 📚 Documentation du code (Dokka)
La documentation générée par **Dokka** se trouve dans le dossier :
- `build/dokka/html/index.html`

---

## 👥 Auteurs
- Ali Benettoumi & Hamza Joual

**Date :** 31 Mai 2026