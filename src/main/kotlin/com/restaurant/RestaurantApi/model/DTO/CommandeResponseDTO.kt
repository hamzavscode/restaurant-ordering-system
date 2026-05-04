package com.restaurant.RestaurantApi.model.DTO

import com.restaurant.RestaurantApi.model.OrderStatus
import java.util.Date

data class CommandeResponseDTO(
    val id: Long,
    val date: Date,
    val status: OrderStatus,
    val client: ClientResponseDTO,
    val elements: List<ElementMenuDTO>
)
