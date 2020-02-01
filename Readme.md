You have essentially 2 options if you want to replicate data from on-premise Oracle database to Redshift :

Option 1 : Use a AWS service for migrating databases to AWS cloud called DMS and SCT. DMS stands for Database Migration Service and is a simple, cost-effective and easy to use service. There is no need to install any drivers or applications, and it does not require changes to the source database in most cases. You can begin a database migration with just a few clicks in the AWS Management Console. 

AWS SCT stands for schema conversion tool. AWS Schema Conversion Tool makes heterogeneous database migrations predictable by automatically converting the source database schema and a majority of the database code objects, including views, stored procedures, and functions, to a format compatible with the target database. (Ref: https://aws.amazon.com/dms/schema-conversion-tool/)

Option 2: Using Non-AWS options like Oracle Golden Gate, Attunity, Alooma etc. Being 3rd party products and having not used any of the products listed in Option 2, i cannot comment on how any of them works or what are there pros and cons. So in this response i will focus on Option 1 which is AWS native database migration service. 

To migrate an Oracle database from on-premise and continue the replication you need to do first setup the network side of things on both on-premise as well as on AWS side. Then you need to provision the DMS and Redshift infrastructure and setup the replication tasks. Let us break the DMS migration steps into 3 broad stages. At each step and stage i will attach the relevant links from our public documentation.

====================================================================
Stage 1 : Network Setup for DMS On-Premise to AWS VPC 
====================================================================

If your On-Premise Oracle Database is not publicly available then you will have to use either Direct connect or VPN. Remote networks can connect to a VPC using several options such as AWS Direct Connect or a software or hardware VPN. If you don't use a VPN or AWS Direct Connect to connect to AWS resources, you can use the internet to migrate an Oracle database to an Amazon Redshift cluster.  

As part of the network to use for database migration, you need to specify what subnets in your Amazon Virtual Private Cloud (Amazon VPC) you plan to use. A subnet is a range of IP addresses in your VPC in a given Availability Zone. These subnets can be distributed among the Availability Zones for the AWS Region where your VPC is located. You create a replication instance in a subnet that you select, and you can manage what subnet a source or target endpoint uses by using the AWS DMS console. 

Please see the below links for more information on the Network setup for DMS

Link 1 : https://docs.aws.amazon.com/dms/latest/userguide/CHAP_ReplicationInstance.VPC.html#CHAP_ReplicationInstance.VPC.Configurations.ScenarioDirect

Link 2 : https://docs.aws.amazon.com/dms/latest/userguide/CHAP_ReplicationInstance.html


====================================================================
Stage 2 : Creation of DMS Replication Instance, Endpoints and Redshift Infrastructure 
====================================================================
In this stage we create the actual DMS instance and the endpoints for Oracle and Redshift.

a) Create Replication Instance
AWS DMS always creates the replication instance in a VPC based on Amazon Virtual Private Cloud (Amazon VPC). You specify the VPC where your replication instance is located. You can use your default VPC for your account and AWS Region, or you can create a new VPC. The VPC must have two subnets in at least one Availability Zone. 

Link 3 : https://docs.aws.amazon.com/dms/latest/userguide/CHAP_ReplicationInstance.VPC.html

b) Before creating the replication endpoint ensure that your Redshift cluster is created and it has all the necessary security group permissions for your DMS instance to access it. If your Redshift cluster is in a different VPC then you will have to do VPC peering to connect to your Redshift cluster in different vpc to DMS instance in another VPC

Link 4 : https://docs.aws.amazon.com/ses/latest/DeveloperGuide/event-publishing-redshift-cluster.html

Link 5 : https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html

c) Create the Endpoints for DMS 
An endpoint provides connection, data store type, and location information about your data store. AWS Database Migration Service uses this information to connect to a data store and migrate data from a source endpoint to a target endpoint.

Link 6 : https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Endpoints.html

You will need to create 2 endpoints. 1 source endpoint for Oracle and 1 target endpoint for Redshift. 

Link 7 : https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Source.Oracle.html#CHAP_Source.Oracle.Configuration | https://aws.amazon.com/premiumsupport/knowledge-center/dms-redshift-target-endpoint/

Link 8 : https://docs.aws.amazon.com/dms/latest/sbs/CHAP_RDSOracle2Redshift.html

It is advisable to run AWS SCT prior and create a project for Oracle to Redshift. It will give you more idea about what are the differences between Oracle and Redshift and if you need to do any manual steps on Redshift side before or after the replication. If you are doing just table replication then you can skip AWS SCT part.  My advise would be to do multiple dry runs with a small pre-prod Oracle database first and see if you are missing any objects/features in Redshift side.

Now once this stage is completed you essentially have the Network, DMS and Redshift infrastructure and are ready to start the replication from Oracle On-Premise to Redshift. 

====================================================================
Stage 3 : Create Replication Task for replicating data in near realtime from On-Premise Oracle to Redshift
====================================================================
This is the final stage of configuration for Oracle to Redshift replication using DMS. In previous 2 stages we already setup the infra. We now have one replication DMS instance, two endpoints - one is your source on-premise Oracle database and the second is the destination Redshift cluster on AWS.

Now the final part is to configure the replication task. DMS uses CDC logminer to capture the changes in Oracle side. Default method of the Oracle source is logminer, so you need to enable supplemental logging on Oracle side.

Enable Supplemental Logging for Oracle:
Link 9 : Normal - https://docs.oracle.com/database/121/SUTIL/GUID-D2DDD67C-E1CC-45A6-A2A7-198E4C142FA3.htm#SUTIL1583
Link 10 : RDS - https://docs.aws.amazon.com/dms/latest/sbs/CHAP_On-PremOracle2Aurora.Steps.ConfigureOracle.html

SQL> alter database force logging;
Database altered.

SQL> ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;
Database altered.

User Account Privileges Required on a Self-Managed Oracle Source for AWS DMS :                  
GRANT SELECT ANY TRANSACTION to dms_user
GRANT SELECT on V_$ARCHIVED_LOG to dms_user
GRANT SELECT on V_$LOG to dms_user
GRANT SELECT on V_$LOGFILE to dms_user
GRANT SELECT on V_$DATABASE to dms_user
GRANT SELECT on V_$THREAD to dms_user
GRANT SELECT on V_$PARAMETER to dms_user
GRANT SELECT on V_$NLS_PARAMETERS to dms_user
GRANT SELECT on V_$TIMEZONE_NAMES to dms_user
GRANT SELECT on V_$TRANSACTION to dms_user
GRANT SELECT on ALL_INDEXES to dms_user
GRANT SELECT on ALL_OBJECTS to dms_user
GRANT SELECT on DBA_OBJECTS to dms_user (required if the Oracle version is earlier than 11.2.0.3)
GRANT SELECT on ALL_TABLES to dms_user
GRANT SELECT on ALL_USERS to dms_user
GRANT SELECT on ALL_CATALOG to dms_user
GRANT SELECT on ALL_CONSTRAINTS to dms_user
GRANT SELECT on ALL_CONS_COLUMNS to dms_user
GRANT SELECT on ALL_TAB_COLS to dms_user
GRANT SELECT on ALL_IND_COLUMNS to dms_user
GRANT SELECT on ALL_LOG_GROUPS to dms_user
GRANT SELECT on SYS.DBA_REGISTRY to dms_user
GRANT SELECT on SYS.OBJ$ to dms_user
GRANT SELECT on DBA_TABLESPACES to dms_user
GRANT SELECT on ALL_TAB_PARTITIONS to dms_user
GRANT SELECT on ALL_ENCRYPTED_COLUMNS to dms_user
GRANT SELECT on V_$LOGMNR_LOGS to dms_user
GRANT SELECT on V_$LOGMNR_CONTENTS to dms_user
GRANT SELECT on V_$STANDBY_LOG to dms_user
                
Following permission is required when using CDC so that AWS DMS can add to Oracle LogMiner redo logs for both 11g and 12c.

Grant EXECUTE ON dbms_logmnr TO dms_user;

Now, we can go ahead and create the replication tasks from Source Oracle to Destination Redshift. Please check the attached link and screenshots for the configuration to be used in this setup.  Ensure to select option 'Migrate existing data and replicate ongoing changes' 

Link 11 : https://docs.aws.amazon.com/dms/latest/sbs/CHAP_RDSOracle2Redshift.Steps.CreateMigrationTask.html

The initial load will take sometime if your Oracle Database/Schema which you are replicating is large and it depends on lot of factors eg: Network bandwidth, if your Oracle source database is busy, CPU and IOPS of your source and destination hardware etc. Like I suggested earlier, before doing a production migration/replication do multiple dry runs so you have the timing narrowed down and are aware of any gotchas. 

Finally do a check and compare your tasks results with expected results 

Link 12 : https://docs.aws.amazon.com/dms/latest/sbs/CHAP_RDSOracle2Redshift.Steps.VerifyDataMigration.html

So once you have completed the above setup you will have a logminer based on-going replication from you on-premise Oracle database to a Redshift cluster.  Few pre-cautions we can recommend for this scenario are  :

1. For migrations with a high volume of changes, LogMiner might have some I/O or CPU impact on the computer hosting the Oracle source database. Binary Reader has less chance of having I/O or CPU impact because the archive logs are copied to the replication instance and mined there. Check this link to learn more on the different reader modes for Oracle :  https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Source.Oracle.html#CHAP_Source.Oracle.Configuration

2. Ensure you always continuously monitor your source and destination endpoints for any performance issues. Specially Oracle, being largely used for transactional systems it can impact your application if the database performance goes south.

3. Primary key constraint is not enforced in Redshift - primary constraint can be defined in DDL but Redshift only keeps the definition in data dictionary. It is possible to have duplicate rows even if a table's DDL has primary key defined.

4. Redshift at its core is an OLAP database/data warehouse unlike Oracle which can do both OLAP and OLTP. Write operations in Redshift are fundamentally slower compared to read operations. Though for the initial load from Oracle to Redshift DMS uses COPY commands but any consequent updates/inserts will be run as a DML on Redshift.  Atomic small inserts/updates can be expensive in Redshift. 

Please refer these blog articles for high level steps for configuring Oracle to Amazon Redshift Migration/Replication :

Link 13 : https://aws.amazon.com/getting-started/projects/migrate-oracle-to-amazon-redshift/
Link 14 :  https://aws.amazon.com/blogs/database/how-to-migrate-your-oracle-data-warehouse-to-amazon-redshift-using-aws-sct-and-aws-dms/
Link 15 : IMPORTANT ! :  https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Source.Oracle.html#CHAP_Source.Oracle.Configuration
Best Practices for DMS : https://docs.aws.amazon.com/dms/latest/userguide/CHAP_BestPractices.html

In conclusion we can easily setup an Oracle to Redshift on-going replication in near real-time using the above approach with DMS. 

