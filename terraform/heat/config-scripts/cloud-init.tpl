#cloud-config
merge_how: dict(recurse_array)+list(append)
final_message: "The instance is up, after $UPTIME seconds"
