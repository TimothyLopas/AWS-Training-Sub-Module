*** Settings ***
Documentation     A custom resource file that allows us to download and upload files into a provided bucket in AWS S3.
Library           DateTime
Library           RPA.Cloud.AWS
Library           RPA.Dialogs
Library           RPA.Robocorp.Vault
Library           String

*** Keywords ***
Upload file to S3 bucket
    [Arguments]    ${bucket_name}=na    ${file_path}=na
    IF    "${bucket_name}"=="na" and "${file_path}"=="na"
        Add heading    AWS File Upload Selection
        Add text input    Bucket_Name    label=Bucket Name
        Add file input    name=File_Path    source=${OUTPUT_DIR}    label=File To Upload
        ${result}=    Run dialog
        ${bucket_name}=    Set Variable    ${result.Bucket_Name}
        ${file_path}=    Set Variable    ${result.File_Path}[0]
    END
    ${path}    ${filename}=    Split String From Right    ${file_path}    separator=${/}    max_split=1
    Upload File    ${bucket_name}    ${file_path}    complete/${filename}
    Log    AWS S3 file upload complete

Download file from S3 bucket
    [Arguments]    ${bucket_name}=na    ${file_name}=na
    IF    "${bucket_name}"!="na" and "${file_name}"!="na"
        @{file_list}=    Create List    ${file_name}
        Download Files    ${bucket_name}    ${file_list}    ${OUTPUT_DIR}
    ELSE
        Add heading    AWS File Download Details
        Add text input    Bucket_Name    label=Bucket Name
        Add text input    File_Name    label=File Name
        ${result}=    Run dialog
        @{file_list}=    Create List    ${result.File_Name}
        Download Files    ${result.Bucket_Name}    ${file_list}    ${OUTPUT_DIR}
    END
    Log    AWS S3 file download complete

Authenticate to S3
    ${secret}=    Get Secret    aws
    Init S3 Client
    ...    ${secret}[AWS_KEY_ID]
    ...    ${secret}[AWS_KEY]
    ...    ${secret}[AWS_REGION]
