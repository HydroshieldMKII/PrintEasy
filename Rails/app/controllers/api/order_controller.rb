# frozen_string_literal: true

module Api
  class OrderController < AuthenticatedController
    def index
      @orders = Order.fetch_for_user(ssf_params)

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

    def report
      sql = <<-SQL
        WITH latest_order_status AS (
          SELECT
            order_id,
            MAX(created_at) AS latest_status_time
          FROM order_status
          GROUP BY order_id
        ),
        basic_order_info AS (
          SELECT
            printer_users.id AS printer_user_id,
            printer_users.printer_id AS printer_id,
            reviews.rating AS rating,
            offers.price AS price,
            orders.id AS order_id,
            order_status.status_name AS status_name,
            order_status.created_at AS created_at
          FROM orders
          LEFT JOIN offers ON orders.offer_id = offers.id
          LEFT JOIN printer_users ON offers.printer_user_id = printer_users.id
          LEFT JOIN order_status ON orders.id = order_status.order_id
          LEFT JOIN reviews ON orders.id = reviews.order_id
          JOIN latest_order_status ON orders.id = latest_order_status.order_id AND order_status.created_at = latest_order_status.latest_status_time
          WHERE printer_users.user_id = #{current_user.id}
          GROUP BY printer_users.id, orders.id
        )
        SELECT
          printers.model AS printer_model,
          SUM(basic_order_info.status_name = 'Arrived') AS completed_orders,
          SUM(basic_order_info.status_name = 'Cancelled') AS cancelled_orders,
          SUM(basic_order_info.status_name = 'Printing' OR basic_order_info.status_name = 'Printed' OR basic_order_info.status_name = 'Shipped' OR basic_order_info.status_name = 'Accepted') AS in_progress_orders,
          AVG(basic_order_info.rating) AS average_rating,
          CAST(
            TRUNCATE(
              SEC_TO_TIME(
                AVG(
                  TIMESTAMPDIFF(
                    SECOND, 
                    (SELECT MIN(order_status.created_at) FROM order_status JOIN orders ON orders.id = order_status.order_id WHERE orders.id = latest_order_status.order_id), 
                    latest_order_status.latest_status_time)
                  )
                ), 
              0
            )
            AS VARCHAR(10)
          ) AS average_time_to_complete,
          SUM(CASE WHEN (basic_order_info.status_name = 'Arrived') THEN basic_order_info.price ELSE 0 END) AS money_earned
        FROM basic_order_info
        JOIN printers ON basic_order_info.printer_id = printers.id
        JOIN latest_order_status ON basic_order_info.order_id = latest_order_status.order_id
        GROUP BY printers.model
      SQL
      results = ActiveRecord::Base.connection.select_all(sql).to_a

      render json: { printers: results, errors: {} }, status: :ok

    end

    private

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

    def ssf_params
      params.permit(:sort, :search, :filter, :type)
    end
  end
end
