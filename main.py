import boto3
x=input("enter")
if x=='1':
    client=boto3.client('ec2')
    response=client.describe_instances()
    for r in response['Reservations']:
        for i in r['Instances']:
            for x in i['Tags']:
                for y in i['State']:
                    if y=='Name':
                        print ("Name: "+x['Value']," Id: "+i['InstanceId']," State: "+ i['State'][y])
    print("  ")
    print("Which action you want to perform?")
    print("To STOP Instance, Enter 1")
    print("To START Instances, Enter 2")
    print("To TERMINATE Instances, Enter 3")
    y=input("Enter your choice: ")
    if y=='1':
        client=boto3.client('ec2')
        response=client.describe_instances()
        for r in response['Reservations']:
            for i 
    
else:
    print("i")
    
                    
                        

    

