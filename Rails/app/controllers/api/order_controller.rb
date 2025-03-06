# frozen_string_literal: true

module Api
  class OrderController < AuthenticatedController
    def index
      @orders = Order.fetch_for_user(params)

      render json: {
        orders: order_as_json(@orders),
        errors: {}
      }, status: :ok
    end

    def show
      @order = Order.joins(offer: [:request, { printer_user: :user }])
                    .where('requests.user_id = ? OR printer_users.user_id = ?', current_user.id, current_user.id)
                    .find(params[:id])

      render json: {
        order: order_as_json(@order),
        errors: {}
      }, status: :ok
    end

    def create
      new_params = { order: { offer_id: params[:id], order_status_attributes: [{ status_name: 'Accepted' }] } }
      @order = Order.new(new_params[:order])
      if @order.save
        render json: { order: order_as_json(@order), errors: {} }, status: :created
      else
        render json: { errors: @order.errors.as_json }, status: :unprocessable_entity
      end
    end

    def order_as_json(order)
      order.as_json(
        except: %i[offer_id],
        include: {
          offer: {
            except: %i[created_at updated_at printer_user_id request_id color_id filament_id],
            include: {
              printer_user: {
                except: %i[printer_id user_id],
                include: {
                  user: {
                    except: %i[country_id],
                    include: { country: {} },
                    methods: %i[profile_picture_url]
                  },
                  printer: { only: %i[id model] }
                }
              },
              request: {
                except: %i[created_at updated_at user_id],
                methods: %i[stl_file_url],
                include: {
                  user: {
                    except: %i[country_id],
                    include: { country: {} },
                    methods: %i[profile_picture_url]
                  },
                  preset_requests: {
                    except: %i[request_id color_id filament_id printer_id],
                    include: {
                      color: {},
                      filament: {},
                      printer: {}
                    }
                  }
                }
              },
              color: {},
              filament: {}
            }
          },
          review: {
            include: {
              user: {
                except: %i[crountry_id],
                include: { country: {} },
                methods: %i[profile_picture_url]
              }
            },
            methods: %i[image_urls]
          },
          order_status: {
            except: %i[order_id],
            methods: %i[image_url]
          }
        },
        methods: %i[available_status]
      )
    end
  end
end
