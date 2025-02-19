class Api::OrderController < ApplicationController
  def index
    if current_user.nil?
      render json: { errors: 'You are not authorized to view this page' }, status: :unauthorized and return
    end

    if params[:type] == 'printer'
      @orders = Order.joins(offer: { printer_user: :user }).where(users: {id: current_user&.id})
    else
      @orders = Order.joins(offer: { request: :user }).where(users: {id: current_user&.id})
    end

    render json: {
      orders: @orders.as_json(
        except: %i[created_at updated_at],
        include: {
          offer: {
            except: %i[created_at updated_at],
            include: {
              printer_user: {
                except: %i[acquired_date],
                include: {
                  user: {
                    except: %i[created_at updated_at is_admin]
                  }
                }
              },
              request: {
                except: %i[created_at updated_at],
                include: {
                  user: {
                    except: %i[created_at updated_at is_admin]
                  }
                }
              }
            }
          },
          review: {
            except: %i[created_at updated_at],
          },
          order_status: {}
        }
      ),
    }, status: :ok
  end

  def show
    @order = Order.find(params[:id])
    if @order.nil?
      render json: { errors: 'Order not found' }, status: :not_found
    end
    if current_user == @order.consumer || current_user == @order.printer

      render json: {
        order: @order.as_json(
          except: %i[created_at updated_at, offer_id],
          include: {
            offer: {
              except: %i[created_at updated_at printer_user_id request_id color_id filament_id],
              include: {
                printer_user: {
                  except: %i[printer_id user_id],
                  include: {
                    user: {
                      except: %i[created_at updated_at is_admin country_id],
                      include: {
                        country: {}
                      }
                    },
                    printer: {}
                  }
                },
                request: {
                  except: %i[created_at updated_at user_id],
                  include: {
                    user: {
                      except: %i[created_at updated_at is_admin],
                      include: {
                        country: {}
                      }
                    }
                  }
                },
                color: {},
                filament: {},
              }
            },
            review: {
              except: %i[created_at updated_at],
            },
            order_status: {
              except: %i[order_id],
            }
          }
        ).merge({ available_status: @order.order_status.last.available_status })
      }, status: :ok
    else
      render json: { errors: 'You are not authorized to view this order' }, status: :unauthorized
    end
  end
end