# **DNAVault: Decentralized Genomic Data Marketplace**  

## **Overview**  
**DNAVault** is a decentralized smart contract built on the Stacks blockchain, designed to facilitate the secure and transparent exchange of genomic data between data owners and researchers. The platform prioritizes privacy, security, and ethical use of genetic information while enabling a seamless marketplace for data access.

## **Features**  
1. **Dataset Registration**  
   Data owners can register and list encrypted genomic datasets for access by verified researchers.  
2. **Researcher Registration & Verification**  
   Researchers can register on the platform, providing their credentials and affiliations. Contract owners can verify researchers to ensure only qualified individuals access sensitive data.  
3. **Access Requests & Approval**  
   Researchers can request access to specific datasets. Data owners can review and approve or deny requests based on their discretion.  
4. **Reputation System**  
   Verified researchers have a reputation score that can be managed by the contract owner. This incentivizes responsible usage of genomic data.  
5. **Governance**  
   The contract owner governs the platform, verifying researchers and updating reputation scores as needed.

---

## **Contract Architecture**  

### **Constants**  
| Name                  | Description                        |
|-----------------------|------------------------------------|
| `ERR-NOT-AUTHORIZED`   | Error for unauthorized access (`u1`). |
| `ERR-INVALID-DATASET`  | Error for invalid dataset ID (`u2`). |
| `ERR-ALREADY-PROCESSED`| Error when a request has already been processed (`u3`). |
| `ERR-PAYMENT-FAILED`   | Error for payment failure (`u4`). |
| `ERR-INVALID-PARAMS`   | Error for invalid parameters (`u5`). |

---

### **Data Variables**  
| Variable              | Type          | Description                        |
|-----------------------|---------------|------------------------------------|
| `dataset-count`        | `uint`        | Counter for registered datasets.   |
| `contract-owner`       | `principal`   | The owner of the DNAVault contract.|

---

### **Data Structures**  

1. **`datasets`**  
   Stores details of registered datasets.  
   ```clarity
   {
       owner: principal,
       encrypted-data-hash: (string-utf8 256),
       metadata-hash: (string-utf8 256),
       price: uint,
       is-available: bool
   }
   ```

2. **`researchers`**  
   Stores details of registered researchers.  
   ```clarity
   {
       name: (string-utf8 100),
       institution: (string-utf8 100),
       credentials: (string-utf8 256),
       is-verified: bool,
       reputation-score: uint
   }
   ```

3. **`access-requests`**  
   Stores researcher access requests for datasets.  
   ```clarity
   {
       researcher: principal,
       approved: bool,
       processed: bool
   }
   ```

---

## **Public Functions**  

### 1. **`register-dataset`**  
Registers a new genomic dataset.  
**Parameters:**  
- `encrypted-data-hash` (string-utf8 256): Hash of the encrypted dataset.  
- `metadata-hash` (string-utf8 256): Hash of the dataset metadata.  
- `price` (uint): Price for accessing the dataset.  

**Returns:** Dataset ID (`uint`) on success.  

---

### 2. **`register-researcher`**  
Registers a new researcher on the platform.  
**Parameters:**  
- `name` (string-utf8 100): Researcher's name.  
- `institution` (string-utf8 100): Affiliated institution.  
- `credentials` (string-utf8 256): Credentials and qualifications.  

**Returns:** `true` on success or an error code.

---

### 3. **`request-access`**  
Requests access to a specific dataset.  
**Parameters:**  
- `dataset-id` (uint): The ID of the dataset.  

**Returns:** `true` on success or an error code.  

---

### 4. **`approve-access`**  
Approves or denies a researcher's request to access a dataset.  
**Parameters:**  
- `dataset-id` (uint): The ID of the dataset.  
- `request-id` (uint): The ID of the access request.  

**Returns:** `true` on success or an error code.

---

### 5. **`verify-researcher`**  
Verifies a researcher's identity and credentials.  
**Parameters:**  
- `researcher` (principal): The researcher's blockchain address.  

**Returns:** `true` on success or an error code.

---

### 6. **`update-reputation`**  
Updates the reputation score of a researcher.  
**Parameters:**  
- `researcher` (principal): The researcher's blockchain address.  
- `score` (uint): The new reputation score.  

**Returns:** `true` on success or an error code.

---

## **Read-Only Functions**  

### 1. **`get-dataset-details`**  
Retrieves the details of a registered dataset.  
**Parameters:**  
- `dataset-id` (uint): The ID of the dataset.  

**Returns:** Dataset details or `none` if the dataset does not exist.

---

### 2. **`get-researcher-profile`**  
Retrieves the profile of a registered researcher.  
**Parameters:**  
- `researcher` (principal): The researcher's blockchain address.  

**Returns:** Researcher details or `none` if the researcher is not registered.

---

### 3. **`get-access-status`**  
Checks if a researcher has access to a specific dataset.  
**Parameters:**  
- `dataset-id` (uint): The ID of the dataset.  
- `researcher` (principal): The researcher's blockchain address.  

**Returns:** `true` if the researcher has access, `false` otherwise.

---

## **Governance**  
The **contract owner** is responsible for:  
- Verifying researchers.  
- Updating researcher reputation scores.  
- Managing platform governance decisions.

## **Security Considerations**  
- **Data Privacy:** Only encrypted data is stored on-chain, ensuring privacy for sensitive genomic information.  
- **Access Control:** Only verified researchers and dataset owners can interact with critical functions.  
- **Error Handling:** Comprehensive error codes are implemented to handle unauthorized access, invalid requests, and incorrect parameters.

## **Future Enhancements**  
- Integration with off-chain storage solutions for secure storage of genomic data.  
- Implementation of payment gateways for seamless data transactions.  
- Advanced reputation mechanisms to incentivize ethical research practices.

## **License**  
This smart contract is licensed under the MIT License.