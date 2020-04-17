output "all_users" {
    description = "all_users map"
    value = aws_iam_user.users
}

output "all_arns" {
    description = "all users arns"
    value = values(aws_iam_user.users)[*].arn
}

output "uppercase_names" {
    description = "all names in uppercase"
    value = [for name in var.usernames : upper(name)]
}