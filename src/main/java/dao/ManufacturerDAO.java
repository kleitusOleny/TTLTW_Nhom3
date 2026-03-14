package dao;

import model.Manufacturer;

import java.util.List;

public class ManufacturerDAO extends ADAO{
    public List<Manufacturer> getAllManufacturers() {
        return jdbi.withHandle(handle -> handle
                .createQuery("SELECT id, manufacturer_name, location FROM manufacturers WHERE is_delete = 0")
                .mapToBean(Manufacturer.class)
                .list());
    }
}
