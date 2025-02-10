resource "github_repository" "todo-list-aws-repository" {
    name = "todo-list-aws-test"
    visibility = "public"

    template {
        owner = "keji-dev"
        repository = "terraform-template-module"
        include_all_branches = true
    }
}