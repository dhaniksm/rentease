
window.onload = function() {
  // Build a system
  var url = window.location.search.match(/url=([^&]+)/);
  if (url && url.length > 1) {
    url = decodeURIComponent(url[1]);
  } else {
    url = window.location.origin;
  }
  var options = {
  "swaggerDoc": {
    "openapi": "3.0.0",
    "info": {
      "title": "RentEase API",
      "version": "1.0.0",
      "description": "Dokumentasi API RentEase"
    },
    "servers": [
      {
        "url": "https://rentase-api.vercel.app"
      },
      {
        "url": "http://localhost:3000"
      }
    ],
    "paths": {
      "/api/vehicles": {
        "get": {
          "summary": "Retrieve a list of all vehicles",
          "tags": [
            "Vehicles"
          ],
          "responses": {
            "200": {
              "description": "A list of vehicles retrieved successfully"
            },
            "500": {
              "description": "Internal server error"
            }
          }
        },
        "post": {
          "summary": "Create a new vehicle",
          "tags": [
            "Vehicles"
          ],
          "requestBody": {
            "required": true,
            "content": {
              "multipart/form-data": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "vehicle_name": {
                      "type": "string"
                    },
                    "brand": {
                      "type": "string"
                    },
                    "vehicle_type": {
                      "type": "string"
                    },
                    "plate_number": {
                      "type": "string"
                    },
                    "price_per_day": {
                      "type": "integer"
                    },
                    "image": {
                      "type": "string",
                      "format": "binary"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Vehicle created successfully"
            },
            "400": {
              "description": "Missing required fields"
            },
            "500": {
              "description": "Internal server error"
            }
          }
        }
      },
      "/api/vehicles/{id}": {
        "get": {
          "summary": "Get vehicle by ID",
          "tags": [
            "Vehicles"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              },
              "description": "The vehicle ID"
            }
          ],
          "responses": {
            "200": {
              "description": "Vehicle detail retrieved successfully"
            },
            "404": {
              "description": "Vehicle not found"
            },
            "500": {
              "description": "Internal server error"
            }
          }
        },
        "put": {
          "summary": "Update an existing vehicle",
          "tags": [
            "Vehicles"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              },
              "description": "The vehicle ID"
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "multipart/form-data": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "vehicle_name": {
                      "type": "string"
                    },
                    "brand": {
                      "type": "string"
                    },
                    "vehicle_type": {
                      "type": "string"
                    },
                    "plate_number": {
                      "type": "string"
                    },
                    "price_per_day": {
                      "type": "integer"
                    },
                    "image": {
                      "type": "string",
                      "format": "binary"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Vehicle updated successfully"
            },
            "404": {
              "description": "Vehicle not found"
            },
            "500": {
              "description": "Internal server error"
            }
          }
        },
        "delete": {
          "summary": "Delete a vehicle",
          "tags": [
            "Vehicles"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              },
              "description": "The vehicle ID"
            }
          ],
          "responses": {
            "200": {
              "description": "Vehicle deleted successfully"
            },
            "404": {
              "description": "Vehicle not found"
            },
            "500": {
              "description": "Internal server error"
            }
          }
        }
      },
      "/api/vehicles/{id}/status": {
        "patch": {
          "summary": "Update vehicle status",
          "tags": [
            "Vehicles"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              },
              "description": "The vehicle ID"
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "status": {
                      "type": "string",
                      "enum": [
                        "available",
                        "rented",
                        "maintenance"
                      ]
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Vehicle status updated successfully"
            },
            "400": {
              "description": "Invalid status value"
            },
            "404": {
              "description": "Vehicle not found"
            },
            "500": {
              "description": "Internal server error"
            }
          }
        }
      },
      "/api/vehicles/{id}/history": {
        "get": {
          "summary": "Get rental history for a vehicle",
          "tags": [
            "Vehicles"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              },
              "description": "The vehicle ID"
            }
          ],
          "responses": {
            "200": {
              "description": "Vehicle rental history retrieved successfully"
            },
            "404": {
              "description": "Vehicle not found"
            },
            "500": {
              "description": "Internal server error"
            }
          },
          "security": [
            {
              "bearerAuth": []
            }
          ]
        }
      },
      "/api/rentals": {
        "get": {
          "summary": "Get all rentals",
          "tags": [
            "Rentals"
          ],
          "parameters": [
            {
              "in": "query",
              "name": "status",
              "schema": {
                "type": "string",
                "enum": [
                  "active",
                  "returned",
                  "late",
                  "cancelled"
                ]
              },
              "description": "Filter rentals by status"
            }
          ],
          "responses": {
            "200": {
              "description": "A list of rentals retrieved successfully"
            },
            "400": {
              "description": "Invalid status value"
            },
            "500": {
              "description": "Internal server error"
            }
          }
        },
        "post": {
          "summary": "Create a new rental transaction",
          "tags": [
            "Rentals"
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "user_id",
                    "vehicle_id",
                    "start_date",
                    "expected_return_date"
                  ],
                  "properties": {
                    "user_id": {
                      "type": "string"
                    },
                    "vehicle_id": {
                      "type": "string"
                    },
                    "start_date": {
                      "type": "string",
                      "format": "date-time"
                    },
                    "expected_return_date": {
                      "type": "string",
                      "format": "date-time"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Rental created successfully"
            },
            "400": {
              "description": "Missing required fields or invalid date ranges"
            },
            "404": {
              "description": "Vehicle not found"
            },
            "500": {
              "description": "Internal server error"
            }
          }
        }
      },
      "/api/rentals/active": {
        "get": {
          "summary": "Get all active rentals",
          "tags": [
            "Rentals"
          ],
          "responses": {
            "200": {
              "description": "Active rentals retrieved successfully"
            },
            "500": {
              "description": "Internal server error"
            }
          }
        }
      },
      "/api/rentals/history/{userId}": {
        "get": {
          "summary": "Get user rental history by User ID",
          "tags": [
            "Rentals"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "userId",
              "required": true,
              "schema": {
                "type": "string"
              },
              "description": "The User ID (UUID)"
            }
          ],
          "responses": {
            "200": {
              "description": "User rental history retrieved successfully"
            },
            "400": {
              "description": "Invalid UUID format"
            },
            "500": {
              "description": "Internal server error"
            }
          }
        }
      },
      "/api/rentals/user/{userId}": {
        "get": {
          "summary": "Get rental history for a user",
          "tags": [
            "Rentals"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "userId",
              "required": true,
              "schema": {
                "type": "string"
              },
              "description": "The User ID (UUID)"
            }
          ],
          "responses": {
            "200": {
              "description": "User rental history retrieved successfully"
            },
            "400": {
              "description": "Invalid UUID format"
            },
            "500": {
              "description": "Internal server error"
            }
          }
        }
      },
      "/api/rentals/verify-vehicle": {
        "post": {
          "summary": "Verify vehicle availability",
          "tags": [
            "Rentals"
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "vehicle_id"
                  ],
                  "properties": {
                    "vehicle_id": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Vehicle verified successfully"
            },
            "400": {
              "description": "Missing vehicle_id or invalid UUID"
            },
            "404": {
              "description": "Vehicle not found"
            },
            "500": {
              "description": "Internal server error"
            }
          }
        }
      },
      "/api/rentals/{id}": {
        "get": {
          "summary": "Get rental by ID",
          "tags": [
            "Rentals"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              },
              "description": "The rental ID"
            }
          ],
          "responses": {
            "200": {
              "description": "Rental detail retrieved successfully"
            },
            "404": {
              "description": "Rental not found"
            },
            "500": {
              "description": "Internal server error"
            }
          }
        }
      },
      "/api/rentals/{id}/return": {
        "put": {
          "summary": "Verify vehicle return and complete rental",
          "tags": [
            "Rentals"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              },
              "description": "The rental ID"
            }
          ],
          "responses": {
            "200": {
              "description": "Rental returned successfully"
            },
            "400": {
              "description": "Rental not active or cannot be returned"
            },
            "404": {
              "description": "Rental not found"
            },
            "500": {
              "description": "Internal server error"
            }
          }
        }
      },
      "/api/rentals/{id}/cancel": {
        "put": {
          "summary": "Cancel an active rental",
          "tags": [
            "Rentals"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              },
              "description": "The rental ID"
            }
          ],
          "responses": {
            "200": {
              "description": "Rental cancelled successfully"
            },
            "400": {
              "description": "Rental not active or cannot be cancelled"
            },
            "404": {
              "description": "Rental not found"
            },
            "500": {
              "description": "Internal server error"
            }
          }
        }
      },
      "/api/payments/confirm/{id}": {
        "patch": {
          "summary": "Confirm rental payment (User)",
          "tags": [
            "Payments"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              },
              "description": "The rental ID"
            }
          ],
          "responses": {
            "200": {
              "description": "Payment confirmation submitted successfully"
            },
            "400": {
              "description": "Invalid status or missing ID"
            },
            "500": {
              "description": "Internal server error"
            }
          }
        }
      },
      "/api/payments/verify/{id}": {
        "patch": {
          "summary": "Verify rental payment (Admin)",
          "tags": [
            "Payments"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              },
              "description": "The rental ID"
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "payment_method"
                  ],
                  "properties": {
                    "payment_method": {
                      "type": "string",
                      "enum": [
                        "cash",
                        "transfer"
                      ],
                      "description": "The payment method used"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Payment verified and vehicle status updated to rented successfully"
            },
            "400": {
              "description": "Invalid payment method or missing parameters"
            },
            "404": {
              "description": "Rental not found"
            },
            "500": {
              "description": "Internal server error"
            }
          }
        }
      },
      "/api/locations": {
        "post": {
          "summary": "Update vehicle location",
          "tags": [
            "Locations"
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "rental_id",
                    "latitude",
                    "longitude"
                  ],
                  "properties": {
                    "rental_id": {
                      "type": "string",
                      "description": "The rental ID"
                    },
                    "latitude": {
                      "type": "number",
                      "format": "float",
                      "description": "Latitude coordinate"
                    },
                    "longitude": {
                      "type": "number",
                      "format": "float",
                      "description": "Longitude coordinate"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Location updated successfully"
            },
            "400": {
              "description": "Missing required fields or rental is not active"
            },
            "404": {
              "description": "Rental not found"
            },
            "500": {
              "description": "Internal server error"
            }
          }
        },
        "get": {
          "summary": "Get all vehicle locations",
          "tags": [
            "Locations"
          ],
          "parameters": [
            {
              "in": "query",
              "name": "page",
              "schema": {
                "type": "integer"
              },
              "description": "Page number"
            },
            {
              "in": "query",
              "name": "limit",
              "schema": {
                "type": "integer"
              },
              "description": "Number of items per page"
            },
            {
              "in": "query",
              "name": "search",
              "schema": {
                "type": "string"
              },
              "description": "Search by rental_id"
            },
            {
              "in": "query",
              "name": "sortBy",
              "schema": {
                "type": "string"
              },
              "description": "Sort field"
            },
            {
              "in": "query",
              "name": "sortOrder",
              "schema": {
                "type": "string",
                "enum": [
                  "asc",
                  "desc"
                ]
              },
              "description": "Sort order"
            }
          ],
          "responses": {
            "200": {
              "description": "A list of locations retrieved successfully"
            },
            "500": {
              "description": "Internal server error"
            }
          }
        }
      },
      "/api/locations/{rentalId}": {
        "get": {
          "summary": "Get vehicle location history for a rental",
          "tags": [
            "Locations"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "rentalId",
              "required": true,
              "schema": {
                "type": "string"
              },
              "description": "The rental ID"
            }
          ],
          "responses": {
            "200": {
              "description": "Location history retrieved successfully"
            },
            "404": {
              "description": "Rental not found"
            },
            "500": {
              "description": "Internal server error"
            }
          }
        },
        "delete": {
          "summary": "Delete all location history for a rental",
          "tags": [
            "Locations"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "rentalId",
              "required": true,
              "schema": {
                "type": "string"
              },
              "description": "The rental ID"
            }
          ],
          "responses": {
            "200": {
              "description": "Location history deleted successfully"
            },
            "404": {
              "description": "Rental not found"
            },
            "500": {
              "description": "Internal server error"
            }
          }
        }
      },
      "/api/locations/{rentalId}/latest": {
        "get": {
          "summary": "Get the latest vehicle location for a rental",
          "tags": [
            "Locations"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "rentalId",
              "required": true,
              "schema": {
                "type": "string"
              },
              "description": "The rental ID"
            }
          ],
          "responses": {
            "200": {
              "description": "Latest location retrieved successfully"
            },
            "404": {
              "description": "Rental or location not found"
            },
            "500": {
              "description": "Internal server error"
            }
          }
        }
      },
      "/api/dashboard/summary": {
        "get": {
          "summary": "Get dashboard summary metrics",
          "tags": [
            "Dashboard"
          ],
          "responses": {
            "200": {
              "description": "Dashboard summary retrieved successfully",
              "content": {
                "application/json": {
                  "schema": {
                    "type": "object",
                    "properties": {
                      "success": {
                        "type": "boolean",
                        "example": true
                      },
                      "data": {
                        "type": "object",
                        "properties": {
                          "total_users": {
                            "type": "integer"
                          },
                          "total_vehicles": {
                            "type": "integer"
                          },
                          "available_vehicles": {
                            "type": "integer"
                          },
                          "rented_vehicles": {
                            "type": "integer"
                          },
                          "maintenance_vehicles": {
                            "type": "integer"
                          },
                          "active_rentals": {
                            "type": "integer"
                          },
                          "completed_rentals": {
                            "type": "integer"
                          },
                          "total_revenue": {
                            "type": "number"
                          },
                          "monthly_revenue": {
                            "type": "number"
                          }
                        }
                      }
                    }
                  }
                }
              }
            },
            "500": {
              "description": "Internal server error"
            }
          }
        }
      },
      "/api/dashboard/recent-transactions": {
        "get": {
          "summary": "Get 5 most recent transactions",
          "tags": [
            "Dashboard"
          ],
          "responses": {
            "200": {
              "description": "Recent transactions retrieved successfully",
              "content": {
                "application/json": {
                  "schema": {
                    "type": "object",
                    "properties": {
                      "success": {
                        "type": "boolean",
                        "example": true
                      },
                      "data": {
                        "type": "array",
                        "items": {
                          "type": "object"
                        }
                      }
                    }
                  }
                }
              }
            },
            "500": {
              "description": "Internal server error"
            }
          }
        }
      }
    },
    "components": {},
    "tags": [
      {
        "name": "Vehicles",
        "description": "Vehicle management API"
      },
      {
        "name": "Rentals",
        "description": "Rental management API"
      },
      {
        "name": "Locations",
        "description": "Vehicle location tracking API"
      },
      {
        "name": "Dashboard",
        "description": "Dashboard metrics and summary API"
      }
    ]
  },
  "customOptions": {}
};
  url = options.swaggerUrl || url
  var urls = options.swaggerUrls
  var customOptions = options.customOptions
  var spec1 = options.swaggerDoc
  var swaggerOptions = {
    spec: spec1,
    url: url,
    urls: urls,
    dom_id: '#swagger-ui',
    deepLinking: true,
    presets: [
      SwaggerUIBundle.presets.apis,
      SwaggerUIStandalonePreset
    ],
    plugins: [
      SwaggerUIBundle.plugins.DownloadUrl
    ],
    layout: "StandaloneLayout"
  }
  for (var attrname in customOptions) {
    swaggerOptions[attrname] = customOptions[attrname];
  }
  var ui = SwaggerUIBundle(swaggerOptions)

  if (customOptions.oauth) {
    ui.initOAuth(customOptions.oauth)
  }

  if (customOptions.preauthorizeApiKey) {
    const key = customOptions.preauthorizeApiKey.authDefinitionKey;
    const value = customOptions.preauthorizeApiKey.apiKeyValue;
    if (!!key && !!value) {
      const pid = setInterval(() => {
        const authorized = ui.preauthorizeApiKey(key, value);
        if(!!authorized) clearInterval(pid);
      }, 500)

    }
  }

  if (customOptions.authAction) {
    ui.authActions.authorize(customOptions.authAction)
  }

  window.ui = ui
}

