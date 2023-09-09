# Terraformcode

-Initialize Azure Provider
-Creating a resource group
-Creating a virtual network
-Creating a subnet within the virtual network
-Creatinga public IP address for the load balancer
-Creatinga load balancer
-Creatingvirtual machines for your application 
-Creatingnetwork interfaces for VMs
-Creating Security Group Rules 
-Associate VMs with the NSG (Network interface Security Group)
-Define Output variables # Terraformcode

    +---------------------+
    | Azure Resource Group|
    |     MPK             |
    +----------+----------+
               |
    +----------v----------+
    |Azure Virtual Network|
    |     mpkvnet         |
    +----------+----------+
               |
    +----------v----------+
    |       Subnet        |
    |     (10.10.1.0/24)  |
    +----+------+---------+
         |      |
         |      |
    +----v------+-----+  +----------------+
    | Public IP Address |  | Azure Load     |
    |     (Static)      |  | Balancer       |
    +-------------------+  | (Load_Balancer)|
                          |                |
                          +------+---------+
                                 |
                        +--------v--------+
                        | Virtual Machines|
                        | (MPK-vm-0/1)    |
                        +--------+--------+
                                 |
                       +---------v--------+
                       | Network Interface|
                       |     Cards (NICs)  |
                       +-------------------+
                                 |
                       +---------v--------+
                       | Network Security |
                       |     Group (NSG)   |
                       |   (MPK-nsg)       |
                       +-------------------+
