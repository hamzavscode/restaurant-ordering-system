package com.restaurant.RestaurantApi.model.DTO

data class ElementMenuDTO(
    val id: Long,
    val nom: String,
    val prix: Double,
    val description: String
)
