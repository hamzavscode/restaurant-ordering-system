package com.restaurant.RestaurantApi.model.DTO

import jakarta.validation.constraints.NotNull
import jakarta.validation.constraints.Pattern

/**
 * DTO (Data Transfer Object) pour les requêtes de création ou de mise à jour d'un [Client].
 *
 * Cette `data class` est utilisée pour transporter et valider les données d'un client
 * (généralement depuis un JSON) lors d'un appel API.
 *
 * @property nom Le nom du client.
 * - Ne doit pas être nul (`@NotNull`).
 * - Doit commencer par une majuscule et être suivi de 2 à 50
 * caractères (lettres, espaces, apostrophes, tirets), selon le `@Pattern`.
 *
 * @see com.restaurant.RestaurantApi.model.Client
 */
data class ClientRequestDTO(
    @field:Pattern(
        regexp = "^[A-Z][a-zA-ZÀ-ÿ\\s'-]{2,50}$",
        message = "Le nom doit commencer par une majuscule et contenir uniquement des lettres et des espaces"
    )
    @field:NotNull(message = "Le nom not null")
    val nom: String,

    @field:jakarta.validation.constraints.Email(message = "Email invalide")
    @field:NotNull(message = "L'email est requis")
    val email: String,

    @field:jakarta.validation.constraints.Size(min = 6, message = "Le mot de passe doit contenir au moins 6 caractères")
    @field:NotNull(message = "Le mot de passe est requis")
    val password: String
)