package gov.state.hhs.service;

import gov.state.hhs.model.Client;
import gov.state.hhs.repository.ClientRepository;
import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import jakarta.validation.Valid;

import java.util.List;
import java.util.Optional;

/**
 * EJB service layer for client management operations.
 * All database interactions go through the repository layer.
 */
@Stateless
public class ClientService {

    @Inject
    private ClientRepository clientRepository;

    public Client save(@Valid Client client) {
        // Normalize fields before saving
        client.setFirstName(capitalize(client.getFirstName()));
        client.setLastName(capitalize(client.getLastName()));
        if (client.getEmail() != null) {
            client.setEmail(client.getEmail().toLowerCase().trim());
        }
        client.setStateCode(client.getStateCode().toUpperCase().trim());
        return clientRepository.save(client);
    }

    public Client update(@Valid Client client) {
        client.setFirstName(capitalize(client.getFirstName()));
        client.setLastName(capitalize(client.getLastName()));
        if (client.getEmail() != null) {
            client.setEmail(client.getEmail().toLowerCase().trim());
        }
        return clientRepository.update(client);
    }

    public Optional<Client> findById(Long id) {
        return clientRepository.findById(id);
    }

    public List<Client> findAll() {
        return clientRepository.findAll();
    }

    public List<Client> search(String term) {
        if (term == null || term.isBlank()) {
            return findAll();
        }
        return clientRepository.searchByName(term);
    }

    public boolean emailInUse(String email) {
        return clientRepository.findByEmail(email).isPresent();
    }

    private String capitalize(String value) {
        if (value == null || value.isBlank()) return value;
        String trimmed = value.trim();
        return Character.toUpperCase(trimmed.charAt(0)) + trimmed.substring(1).toLowerCase();
    }
}
