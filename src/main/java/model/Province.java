package model;

import org.jdbi.v3.core.mapper.reflect.ColumnName;

public class Province {
    @ColumnName("id")
    private String id;
    @ColumnName("province_name")
    private String provinceName;

    public Province() {}

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getProvinceName() {
        return provinceName;
    }

    public void setProvinceName(String provinceName) {
        this.provinceName = provinceName;
    }
}
