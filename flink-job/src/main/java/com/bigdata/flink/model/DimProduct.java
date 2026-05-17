package com.bigdata.flink.model;

import java.io.Serializable;

public class DimProduct implements Serializable {
    private Integer productId;
    private String productName;
    private String category;
    private Double price;
    private Integer quantity;
    private String brand;
    private String size;
    private String material;
    private String color;
    private Double weight;
    private String petCategory;
    private Double rating;
    private Integer reviews;

    public DimProduct() {}

    public DimProduct(Integer productId, String productName, String category,
                      Double price, Integer quantity, String brand, String size,
                      String material, String color, Double weight, String petCategory,
                      Double rating, Integer reviews) {
        this.productId = productId;
        this.productName = productName;
        this.category = category;
        this.price = price;
        this.quantity = quantity;
        this.brand = brand;
        this.size = size;
        this.material = material;
        this.color = color;
        this.weight = weight;
        this.petCategory = petCategory;
        this.rating = rating;
        this.reviews = reviews;
    }

    public Integer getProductId() { return productId; }
    public String getProductName() { return productName; }
    public String getCategory() { return category; }
    public Double getPrice() { return price; }
    public Integer getQuantity() { return quantity; }
    public String getBrand() { return brand; }
    public String getSize() { return size; }
    public String getMaterial() { return material; }
    public String getColor() { return color; }
    public Double getWeight() { return weight; }
    public String getPetCategory() { return petCategory; }
    public Double getRating() { return rating; }
    public Integer getReviews() { return reviews; }

    public void setProductId(Integer productId) { this.productId = productId; }
    public void setProductName(String productName) { this.productName = productName; }
    public void setCategory(String category) { this.category = category; }
    public void setPrice(Double price) { this.price = price; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
    public void setBrand(String brand) { this.brand = brand; }
    public void setSize(String size) { this.size = size; }
    public void setMaterial(String material) { this.material = material; }
    public void setColor(String color) { this.color = color; }
    public void setWeight(Double weight) { this.weight = weight; }
    public void setPetCategory(String petCategory) { this.petCategory = petCategory; }
    public void setRating(Double rating) { this.rating = rating; }
    public void setReviews(Integer reviews) { this.reviews = reviews; }
}
