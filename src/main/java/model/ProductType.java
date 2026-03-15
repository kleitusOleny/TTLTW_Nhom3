package model;

import org.jdbi.v3.core.mapper.reflect.ColumnName;

public class ProductType {
    @ColumnName("id")
    private int id;

    @ColumnName("type_name")
    private String typeName;

    @ColumnName("is_delete")
    private boolean isDelete;

    public ProductType() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTypeName() {
        return typeName;
    }

    public void setTypeName(String typeName) {
        this.typeName = typeName;
    }

    public boolean isDelete() {
        return isDelete;
    }

    public void setDelete(boolean delete) {
        isDelete = delete;
    }
}