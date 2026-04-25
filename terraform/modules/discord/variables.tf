variable "bot_name" {
  type        = string
  default     = "discord"
  description = "Name for the bot — used as namespace, deployment, and secret names"
}

variable "discord_image" {
  type        = string
  description = "Docker image to deploy (e.g. ghcr.io/user/repo:tag)"
}

variable "discord_token" {
  type        = string
  sensitive   = true
  description = "Discord bot token from https://discord.com/developers/applications"
}

variable "github_username" {
  type        = string
  description = "GitHub username for GHCR image pull"
}

variable "github_pat" {
  type        = string
  sensitive   = true
  description = "GitHub PAT with read:packages permission for GHCR image pull"
}
