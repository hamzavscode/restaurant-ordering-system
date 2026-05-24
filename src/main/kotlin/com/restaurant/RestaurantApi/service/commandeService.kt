package com.restaurant.RestaurantApi.service

import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.module.kotlin.readValue
import com.restaurant.RestaurantApi.model.Commande
import com.restaurant.RestaurantApi.model.DTO.*
import com.restaurant.RestaurantApi.repository.CommandeRepository
import com.restaurant.RestaurantApi.repository.ClientRepository
import com.restaurant.RestaurantApi.repository.ElementMenuRepository
import org.springframework.stereotype.Service
import java.util.*

/**
 * Service gérant la logique métier complexe pour les [Commande].
 */
@Service
class CommandeService(
    private val commandeRepository: CommandeRepository,
    private val clientRepository: ClientRepository,
    private val elementMenuRepository: ElementMenuRepository,
    private val objectMapper: ObjectMapper
) {

    fun getAllCommandes(): List<Commande> = commandeRepository.findAll()

    fun getCommandeById(id: Long): Commande =
        commandeRepository.findById(id).orElseThrow { RuntimeException("Commande non trouvée") }

    /**
     * Converts a Commande entity to a CommandeResponseDTO.
     * Expands the elements list based on stored quantities.
     */
    fun toResponseDTO(commande: Commande): CommandeResponseDTO {
        val quantities = parseQuantities(commande.quantitiesJson)

        // Build the expanded elements list with quantities
        val expandedElements = mutableListOf<ElementMenuDTO>()
        for (element in commande.elements) {
            val qty = quantities[element.id.toString()] ?: 1
            repeat(qty) {
                expandedElements.add(
                    ElementMenuDTO(
                        id = element.id!!,
                        nom = element.nom,
                        prix = element.prix,
                        description = element.description
                    )
                )
            }
        }

        return CommandeResponseDTO(
            id = commande.id!!,
            date = commande.date,
            status = commande.status,
            client = ClientResponseDTO(
                id = commande.client.id!!,
                nom = commande.client.nom,
                email = commande.client.email,
                role = commande.client.role
            ),
            elements = expandedElements
        )
    }

    /**
     * Crée une nouvelle commande.
     * Stocke les éléments distincts dans la table de jonction ManyToMany,
     * et les quantités dans le champ quantitiesJson.
     */
    fun createCommande(request: CommandeRequest): CommandeResponseDTO {
        val client = clientRepository.findById(request.clientId)
            .orElseThrow { NoSuchElementException("Client avec ID ${request.clientId} n'a pas été trouvé.") }

        // Validate all requested element IDs exist
        val distinctIds = request.elementIds.distinct()
        val existingElements = elementMenuRepository.findAllById(distinctIds)

        if (existingElements.size != distinctIds.size) {
            val foundIds = existingElements.map { it.id }
            val missingIds = distinctIds.filter { it !in foundIds }
            throw NoSuchElementException("Les éléments de menu avec IDs suivants sont introuvables: $missingIds")
        }

        // Count quantities: {4: 3, 7: 1}
        val quantityMap = request.elementIds.groupingBy { it.toString() }.eachCount()

        // Build the commande with distinct elements + quantities JSON
        val newCommande = Commande(
            client = client,
            quantitiesJson = objectMapper.writeValueAsString(quantityMap)
        )
        newCommande.elements.addAll(existingElements)

        val saved = commandeRepository.save(newCommande)

        return toResponseDTO(saved)
    }

    fun updateCommande(id: Long, clientId: Long?, elementIds: List<Long>?): Commande {
        val commande = getCommandeById(id)

        if (clientId != null) {
            val newClient = clientRepository.findById(clientId)
                .orElseThrow { RuntimeException("Client non trouvé") }
            commande.client = newClient
        }

        if (elementIds != null) {
            val distinctIds = elementIds.distinct()
            val newElements = elementMenuRepository.findAllById(distinctIds)
            commande.elements.clear()
            commande.elements.addAll(newElements)

            val quantityMap = elementIds.groupingBy { it.toString() }.eachCount()
            commande.quantitiesJson = objectMapper.writeValueAsString(quantityMap)
        }

        commande.date = Date()
        return commandeRepository.save(commande)
    }

    fun deleteCommande(id: Long) {
        commandeRepository.deleteById(id)
    }

    private fun parseQuantities(json: String?): Map<String, Int> {
        if (json.isNullOrBlank()) return emptyMap()
        return try {
            objectMapper.readValue(json)
        } catch (e: Exception) {
            emptyMap()
        }
    }
}
