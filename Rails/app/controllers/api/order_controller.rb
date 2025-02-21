class Api::OrderController < ApplicationController
  def index
    if current_user.nil?
      render json: { errors: {order: ['You are not authorized to view this page']} }, status: :unauthorized and return
    end

    if params[:type] == 'printer'
      @orders = Order.joins(offer: { printer_user: :user }).where(users: {id: current_user&.id})
    else
      @orders = Order.joins(offer: { request: :user }).where(users: {id: current_user&.id})
    end

    render json: {
      orders: @orders.as_json(
        except: %i[offer_id],
        include: {
          offer: {
            except: %i[created_at updated_at printer_user_id request_id color_id filament_id],
            include: {
              printer_user: {
                except: %i[printer_id user_id],
                include: {
                  user: {
                    except: %i[created_at updated_at is_admin],
                    methods: %i[profile_picture_url],
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
                    methods: %i[profile_picture_url],
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
            include: {
              user: {
                except: %i[created_at updated_at is_admin],
                methods: %i[profile_picture_url],
                include: {
                  country: {}
                }
              }
            }
          },
          order_status: {
            except: %i[order_id],
            methods: %i[image_url]
          }
        }
      ),
      errors: {}
    }, status: :ok
  end

  def show
    @order = Order.find(params[:id]) rescue nil
    if @order.nil?
      render json: { errors: {order: ['Order not found']} }, status: :not_found and return
    end
    if current_user == @order.consumer || current_user == @order.printer
      available_status = @order.order_status.last.available_status
      if current_user == @order.consumer && @order.order_status.last.status_name != 'Accepted'
        available_status.delete('Cancelled')
      end
      if current_user == @order.printer
        available_status.delete('Arrived')
      end

      render json: {
        order: @order.as_json(
          except: %i[offer_id],
          include: {
            offer: {
              except: %i[created_at updated_at printer_user_id request_id color_id filament_id],
              include: {
                printer_user: {
                  except: %i[printer_id user_id],
                  include: {
                    user: {
                      except: %i[created_at updated_at is_admin],
                      methods: %i[profile_picture_url],
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
                      methods: %i[profile_picture_url],
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
              include: {
                user: {
                  except: %i[created_at updated_at is_admin],
                  methods: %i[profile_picture_url],
                  include: {
                    country: {}
                  }
                }
              }
            },
            order_status: {
              except: %i[order_id],
              methods: %i[image_url]
            }
          }
        ).merge({ available_status: available_status }),
        errors: {}
      }, status: :ok
    else
      render json: { errors: {order: ['You are not authorized to view this order']} }, status: :unauthorized
    end
  end
end