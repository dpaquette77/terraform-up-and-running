
output "neo_arn" {
    description = "arn for user Neo"
    value = aws_iam_user.matrix_users[0].arn
}

output "trinity_arn" {
    description = "arn for user Trinity"
    value = aws_iam_user.matrix_users[2].arn
}

output "morpheus_arn" {
    description = "arn for user Morpheus"
    value = aws_iam_user.matrix_users[1].arn
}

output "all_user_arns" {
    description = "arn of all users"
    value = aws_iam_user.matrix_users[*].arn
}