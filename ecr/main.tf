provider "aws" {
  region = var.aws_region
}

resource "aws_ecr_repository" "ecr_point_management" {
  name = var.point_management_service
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository_policy" "ecr_policy_point_management" {
  repository = aws_ecr_repository.ecr_point_management.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "AllowPushPullImage",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
  EOF
}

resource "aws_ecr_lifecycle_policy" "lifecycle_point_management" {
 repository = aws_ecr_repository.ecr_point_management.name
 policy = jsonencode({
   rules = [{
     rulePriority = 1
     description  = "last 5 docker images"
     action = {
       type = "expire"
     }
     selection = {
       tagStatus   = "any"
       countType   = "imageCountMoreThan"
       countNumber = 5
     }
   }]
 })
}
