package com.restaurant.RestaurantApi.model.DTO

import com.restaurant.RestaurantApi.model.Role

data class ClientResponseDTO(
    val id: Long,
    val nom: String,
    val email: String,
    val role: Role
)
