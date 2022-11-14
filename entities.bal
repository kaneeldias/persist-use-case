import ballerina/time;
import ballerina/persist;

@persist:Entity {
    key: ["requirementId"]
}
public type RequirementList record {
    readonly int requirementId;
    string name;

    // Many-to-many
    // MedicalNeed[] items; // e.g. [10,000 vaccs, 200k panadol, ..]
};

@persist:Entity {
    key: ["needId"]
}
public type MedicalNeed record {
    @persist:AutoIncrement
    readonly int needId = -1;

    @persist:Relation { keyColumns: ["itemId"], reference: ["itemId"] }
    MedicalItem item?;
    
    int beneficiaryId; 
    time:Civil period;
    string urgency;
    int quantity;
};

@persist:Entity {
    key: ["itemId"]
}
public type MedicalItem record {
    @persist:AutoIncrement
    readonly int itemId = -1; 

    string name;
    string 'type;
    string unit;  
};

@persist:Entity {
    key: ["supplierId"]
}
public type SupplierInfo record {
    @persist:AutoIncrement
    readonly int supplierId = -1;

    string name;
    string shortName;
    string email; 
    string phoneNumber;

    //One-to-many
    Quote[] quotes?;
};

@persist:Entity {
    key: ["quoteId"]
}
public type Quote record {
    @persist:AutoIncrement
    readonly int quoteId = -1;

    // One-to-many
    @persist:Relation {keyColumns: ["supplierId"], reference: ["supplierId"]}
    SupplierInfo supplier?;

    @persist:Relation {keyColumns: ["itemId"], reference: ["itemId"]}
    MedicalItem item?;

    int maxQuantity;
    int period;
    string brandName;
    int unitPrice;
    int expiryDate;
    string regulatoryInfo;
};

@persist:Entity {
    key: ["packageId"]
}
public type AidPackage record { // e.g. an order to one supplier
    @persist:AutoIncrement
    readonly int packageId = -1;

    int description;
    string name;
    string status;
    
    @persist:Relation { keyColumns: ["supplierId"], reference: ["supplierId"] }
    SupplierInfo supplier?;
};

@persist:Entity {
    key: ["id"]
}
public type AidPackageOrderItem record {
    @persist:AutoIncrement
    readonly int id = -1;

    @persist:Relation { keyColumns: ["packageId"], reference: ["packageId"] }
    AidPackage package?;

    @persist:Relation { keyColumns: ["needId"], reference: ["needId"] }
    MedicalNeed medicalNeed?;

    int quantity; 

    @persist:Relation { keyColumns: ["supplierId"], reference: ["supplierId"] }
    SupplierInfo supplier?;

    @persist:Relation
    Quote quotation; 

    int totalAmount;
};

@persist:Entity {
    key: ["pledgeId"]
}
public type Pledge record {
    @persist:AutoIncrement
    readonly int pledgeId = -1;

    @persist:Relation { keyColumns: ["packageId"], reference: ["packageId"] }
    AidPackage package?;

    @persist:Relation { keyColumns: ["donorId"], reference: ["donorId"] }
    Donor donor?;

    int amount; 
    string status;
};

@persist:Entity {
    key: ["donorId"]
}
public type Donor record {
    @persist:AutoIncrement
    readonly int donorId = -1; 

    string orgName;
    string orgLink;
    string email; 
    int phone; 
    Quote quotation;
};

@persist:Entity {
    key: ["id"]
}
public type DonorAidPackage record { // e.g. an order to one supplier
    @persist:AutoIncrement
    readonly int id = -1;
    
    @persist:Relation { keyColumns: ["packageId"], reference: ["packageId"] }
    AidPackage package?;

    string description;
    string name;
    string status;

    @persist:Relation { keyColumns: ["supplierId"], reference: ["supplierId"] }
    SupplierInfo supplier?;
    
    // many-to-many
    // DonorAidPackageOrderItem[] orderItems;
    int totalAmount; 
    decimal pledgedPercentage;  
};

@persist:Entity {
    key: ["id"]
}
public type DonorAidPackageOrderItem record {
    @persist:AutoIncrement
    readonly int id = -1;

    @persist:Relation { keyColumns: ["itemId"], reference: ["itemId"] }
    MedicalItem item?;

    int quantity; 
};
