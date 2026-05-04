package com.restaurant.RestaurantApi.service

import org.springframework.stereotype.Service
import com.restaurant.RestaurantApi.model.Client
import com.restaurant.RestaurantApi.repository.ClientRepository
import com.restaurant.RestaurantApi.model.DTO.ClientRequestDTO
/**
 * Service gérant la logique métier pour les entités [Client].
 *
 * * Contient toute la logique métier pour les opérations liées aux
 * clients :
 * * création, modification, suppression, recherche, etc.
 * *
 * Ce service agit comme une couche intermédiaire entre lescontrôleurs
 * * et les repositories
 *
 * @param clientRepository Le repository pour l'accès aux données des [Client].
 */
@Service
class ClientService(private val clientRepository: ClientRepository) {
    /**
     * Récupère la liste complète de tous les clients.
     *
     * @return Une [List] de tous les [Client] présents en base de données.
     * Peut retourner une liste vide si aucun client n'existe.
     */
    fun getAllClients(): List<Client> = clientRepository.findAll()
    /**
     * Récupère un étudiant spécifique par son identifiant.
     *
     * @param id L'identifiant unique de l'étudiant à récupérer
     * @return L'étudiant correspondant à l'identifiant
     * @throws RuntimeException Si aucun étudiant n'existe
    avec cet ID
     *
     * Exemple d'utilisation :
     * ```
     * val c = ClientService.getClientById(5)
     * println(c.nom)
     * ```
     */
     fun getClientById(id: Long): Client  =
        clientRepository.findById(id).orElseThrow { RuntimeException("Client non trouvé") }
    /**
     * Crée un nouvel Client dans le système.
     *
     * @param Client Les données du nouvel étudiant à créer
     * @return L'étudiant créé avec son ID généré automatiquement

     * Exemple d'utilisation :
     * ```
     * val nouvelC = Client(
     * nom = "hamza"
     * )
     * val ClientCree = ClientService.saveClient(nouvelC)
     * ```
     */
    fun saveClient(request: ClientRequestDTO): com.restaurant.RestaurantApi.model.DTO.ClientResponseDTO {
        if (clientRepository.findByEmail(request.email) != null) {
            throw RuntimeException("Email déjà utilisé")
        }
        val client = Client(
            nom = request.nom,
            email = request.email,
            password = request.password
        )
        val saved = clientRepository.save(client)
        return com.restaurant.RestaurantApi.model.DTO.ClientResponseDTO(
            id = saved.id!!,
            nom = saved.nom,
            email = saved.email,
            role = saved.role
        )
    }

    fun loginClient(email: String, password: String): com.restaurant.RestaurantApi.model.DTO.ClientResponseDTO {
        val client = clientRepository.findByEmail(email)
            ?: throw RuntimeException("Email ou mot de passe incorrect")

        if (client.password != password) {
            throw RuntimeException("Email ou mot de passe incorrect")
        }

        return com.restaurant.RestaurantApi.model.DTO.ClientResponseDTO(
            id = client.id!!,
            nom = client.nom,
            email = client.email,
            role = client.role
        )
    }

    /**
     * Met à jour les informations d'un Client existant.
     *
     * Seules les informations fournies seront modifiées.
     * L'ID de Client ne peut pas être modifié.
     *
     * @param id L'identifiant de l'Client à modifier
     * @param Client Les nouvelles données de l'étudiant
     * @return L'étudiant mis à jour avec toutes ses nouvelles
    informations
     * @throws RuntimeException Si le client avec cet ID
    non trouvé

     *
     * Exemple d'utilisation :
     * ```
     * val ClientModifie = etudiant.copy(nom = Ali)
     * ClientService.updateClient(5, ClientModifie)
     * ```
     */

    fun updateClient(id: Long,request: ClientRequestDTO): Client  {
        val existing = clientRepository.findById(id)
            .orElseThrow { RuntimeException("Client non trouvé") }
        existing.nom=request.nom
        val updated = clientRepository.save(existing)
        return updated
    }
    /**
     * Supprime un client de la base de données par son identifiant.
     *
     * Si l'ID n'existe pas, la méthode peut ne rien faire ou lever une
     * exception selon l'implémentation de Spring Data JPA.
     *
     * @param id L'identifiant unique du client à supprimer.
     */
    fun deleteClient(id: Long) = clientRepository.deleteById(id)

}
