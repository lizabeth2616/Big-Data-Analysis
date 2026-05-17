package com.bigdata.flink.model;

import java.io.Serializable;
import java.sql.Date;

public class FactSale implements Serializable {
    private String saleId;
    private Date dateKey;
    private Integer customerId;
    private Integer sellerId;
    private Integer productId;
    private Integer quantity;
    private Double totalPrice;

    public FactSale() {}

    public FactSale(String saleId, Date dateKey, Integer customerId,
                    Integer sellerId, Integer productId, Integer quantity,
                    Double totalPrice) {
        this.saleId = saleId;
        this.dateKey = dateKey;
        this.customerId = customerId;
        this.sellerId = sellerId;
        this.productId = productId;
        this.quantity = quantity;
        this.totalPrice = totalPrice;
    }

    public String getSaleId() { return saleId; }
    public Date getDateKey() { return dateKey; }
    public Integer getCustomerId() { return customerId; }
    public Integer getSellerId() { return sellerId; }
    public Integer getProductId() { return productId; }
    public Integer getQuantity() { return quantity; }
    public Double getTotalPrice() { return totalPrice; }

    public void setSaleId(String saleId) { this.saleId = saleId; }
    public void setDateKey(Date dateKey) { this.dateKey = dateKey; }
    public void setCustomerId(Integer customerId) { this.customerId = customerId; }
    public void setSellerId(Integer sellerId) { this.sellerId = sellerId; }
    public void setProductId(Integer productId) { this.productId = productId; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
    public void setTotalPrice(Double totalPrice) { this.totalPrice = totalPrice; }
}
