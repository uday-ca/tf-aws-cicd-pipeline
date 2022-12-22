resource "aws_iam_role" "Trz_lambda_role" {
    name = "Trz_lambda_role"
    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }]
    }) 
}

resource "aws_iam_policy_attachment" "Trz_role_lambda_policy_attachment" {
    name = "Trz_role_lambda_policy_attachment"
    roles = [ aws_iam_role.Trz_lambda_role.name ]
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "Trz_lambda_source_archive" {
  type = "zip"

  source_dir  = "${path.module}/src"
  output_path = "${path.module}/my-deployment.zip"
}
resource "aws_lambda_function" "Trz_lambda-cicd" {
    function_name = "Trz_lambda-cicd"
    filename = "${path.module}/my-deployment.zip"

    runtime = "python3.7"
    handler = "lambda_function.lambda_handler"
    memory_size = 256

    source_code_hash = data.archive_file.Trz_lambda_source_archive.output_base64sha256

    role = aws_iam_role.Trz_lambda_role.arn
    
    layers = [
        "arn:aws:lambda:us-east-1:933195066766:layer:trz-python-dependencies:1"
    ]
}
resource "aws_cloudwatch_log_group" "Trz_lambda-cicd" {
  name = "/aws/lambda/${aws_lambda_function.Trz_lambda-cicd.function_name}"

  retention_in_days = 1
}
