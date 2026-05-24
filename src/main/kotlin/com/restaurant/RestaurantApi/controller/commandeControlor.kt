package com.restaurant.RestaurantApi.controller


import com.restaurant.RestaurantApi.model.Commande
import com.restaurant.RestaurantApi.model.DTO.CommandeRequest
import com.restaurant.RestaurantApi.model.DTO.CommandeResponseDTO
import com.restaurant.RestaurantApi.service.CommandeService
import org.springframework.web.bind.annotation.*

/**
 * Contrôleur REST pour la gestion des [Commande].
 *
 * Expose les endpoints HTTP pour créer, lire, mettre à jour et supprimer
 * des commandes. Tous les endpoints retournent des données au format JSON.
 *
 * **Base URL** : `/api/commandes`
 */
@RestController
@RequestMapping("/api/commandes")
class CommandeController(
    private val commandeService: CommandeService
) {

    /**
     * GET /api/commandes
     * Récupère la liste complète de toutes les commandes (avec quantités expansées).
     */
    @GetMapping
    fun getAllCommandes(): List<CommandeResponseDTO> {
        val commandes = commandeService.getAllCommandes()
        return commandes.map { commandeService.toResponseDTO(it) }
    }

    /**
     * GET /api/commandes/{id}
     * Récupère une commande spécifique par son identifiant (avec quantités expansées).
     */
    @GetMapping("/{id}")
    fun getCommandeById(@PathVariable id: Long): CommandeResponseDTO {
        val commande = commandeService.getCommandeById(id)
        return commandeService.toResponseDTO(commande)
    }

    /**
     * POST /api/commandes
     * Crée une nouvelle commande.
     */
    @PostMapping
    fun createCommande(@RequestBody request: CommandeRequest): CommandeResponseDTO =
        commandeService.createCommande(request)

    /**
     * PUT /api/commandes/{id}
     * Met à jour une commande existante.
     */
    @PutMapping("/{id}")
    fun updateCommande(
        @PathVariable id: Long,
        @RequestParam(required = false) clientId: Long?,
        @RequestParam(required = false) elementIds: List<Long>?
    ): Commande =
        commandeService.updateCommande(id, clientId, elementIds)

    /**
     * DELETE /api/commandes/{id}
     * Supprime une commande.
     */
    @DeleteMapping("/{id}")
    fun deleteCommande(@PathVariable id: Long) =
        commandeService.deleteCommande(id)
}
