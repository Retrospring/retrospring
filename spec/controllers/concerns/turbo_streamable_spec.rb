# frozen_string_literal: true

require "rails_helper"

describe TurboStreamable, type: :controller do
  controller do
    include TurboStreamable

    turbo_stream_actions :create, :blocked, :not_found

    def create
      params.require :message

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: render_toast("success!")
        end
      end
    end

    def blocked
      raise Errors::Blocked
    end

    def not_found
      raise ActiveRecord::RecordNotFound
    end
  end

  before do
    routes.draw do
      get "create" => "anonymous#create"
      get "blocked" => "anonymous#blocked"
      get "not_found" => "anonymous#not_found"
    end
  end

  render_views

  shared_examples_for "it returns a toast as Turbo Stream response" do |action, message|
    subject { get action, format: :turbo_stream }

    it "returns a toast as Turbo Stream response" do
      subject

      expect(response.header["Content-Type"]).to include "text/vnd.turbo-stream.html"
      expect(response.body).to include message
    end
  end

  describe "#create" do
    context "gets called with the proper parameters" do
      subject { get :create, format: :turbo_stream, params: { message: "test" } }

      it "returns a toast as Turbo Stream response" do
        subject

        expect(response.header["Content-Type"]).to include "text/vnd.turbo-stream.html"
        expect(response.body).to include "success!"
      end
    end

    context "gets called with the wrong parameters" do
      it_behaves_like "it returns a toast as Turbo Stream response", :create, "Message is required"
    end
  end

  it_behaves_like "it returns a toast as Turbo Stream response", :create, "Message is required"
  it_behaves_like "it returns a toast as Turbo Stream response", :blocked, "You have been blocked from performing this request"
  it_behaves_like "it returns a toast as Turbo Stream response", :not_found, "Record not found"
end
