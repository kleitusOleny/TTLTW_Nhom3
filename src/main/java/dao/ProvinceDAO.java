package dao;

import model.Province;
import java.util.List;
import java.util.Optional;

public class ProvinceDAO extends ADAO implements IDAO<Province, String> {

    @Override
    public List<Province> findAll() {
        return jdbi.withHandle(handle ->
            handle.createQuery("SELECT id, province_name FROM provinces ORDER BY province_name ASC")
                .mapToBean(Province.class)
                .list()
        );
    }

    @Override
    public Optional<Province> findById(String id) {
        return jdbi.withHandle(handle ->
            handle.createQuery("SELECT id, province_name FROM provinces WHERE id = :id")
                .bind("id", id)
                .mapToBean(Province.class)
                .findFirst()
        );
    }

    @Override
    public Province save(Province entity) {
        jdbi.useHandle(handle ->
            handle.createUpdate("INSERT INTO provinces (id, province_name) VALUES (:id, :province_name) " +
                                "ON DUPLICATE KEY UPDATE province_name = :province_name")
                .bindBean(entity)
                .execute()
        );
        return entity;
    }

    @Override
    public boolean deleteById(String id) {
        return jdbi.withHandle(handle ->
            handle.createUpdate("DELETE FROM provinces WHERE id = :id")
                .bind("id", id)
                .execute() > 0
        );
    }

    @Override
    public boolean existsById(String id) {
        return findById(id).isPresent();
    }
}
