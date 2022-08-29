import Config

config :starkbank,
  language: "en-US",
  project: [
    environment: :sandbox,
    # "9999999999999999",
    id: System.get_env("SANDBOX_ID"),
    # "-----BEGIN EC PRIVATE KEY-----\nMHQCAQEEIBEcEJZLk/DyuXVsEjz0w4vrE7plPXhQxODvcG1Jc0WToAcGBSuBBAAK\noUQDQgAE6t4OGx1XYktOzH/7HV6FBukxq0Xs2As6oeN6re1Ttso2fwrh5BJXDq75\nmSYHeclthCRgU8zl6H1lFQ4BKZ5RCQ==\n-----END EC PRIVATE KEY-----"
    private_key: System.get_env("SANDBOX_PRIVATE_KEY")
  ]
