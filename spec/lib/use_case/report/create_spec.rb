# frozen_string_literal: true

require "rails_helper"

describe UseCase::Report::Create do
  subject do
    UseCase::Report::Create.call(
      reporter_id: reporter.id,
      object_id:   object_id,
      object_type: object_type,
      reason:      reason,
    )
  end

  let(:reason) { "Inappropriate content" }

  shared_examples "creates the report" do
    it "creates the report" do
      expect { subject }.to change { Report.count }.by(1)
      report = Report.last
      expect(report.reason).to eq(reason)
      expect(report.user_id).to eq(reporter.id)
      expect(report.target_id).to eq(object.id)
      expect(report.type).to eq("Reports::#{object.class}")
    end
  end

  shared_examples "invalid object type" do
    it "raises an error" do
      expect { subject }.to raise_error(Errors::BadRequest, "Unknown object type")
    end
  end

  shared_examples "object not found" do
    it "raises an error" do
      expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "valid object type and existing object" do
    let(:reporter) { FactoryBot.create(:user) }

    context "object type is 'user'" do
      let(:object_type) { "user" }
      let(:object) { FactoryBot.create(:user) }
      let(:object_id) { object.screen_name }

      it_behaves_like "creates the report"
    end

    context "object type is 'question'" do
      let(:object_type) { "question" }
      let(:object) { FactoryBot.create(:question) }
      let(:object_id) { object.id.to_s }

      it_behaves_like "creates the report"
    end

    context "object type is 'answer'" do
      let(:object_type) { "answer" }
      let(:object) { FactoryBot.create(:answer, user: FactoryBot.create(:user)) }
      let(:object_id) { object.id.to_s }

      it_behaves_like "creates the report"
    end

    context "object type is 'comment'" do
      let(:object_type) { "comment" }
      let(:object) do
        FactoryBot.create(:comment,
                          answer: FactoryBot.create(:answer, user: FactoryBot.create(:user)),
                          user:   FactoryBot.create(:user),)
      end
      let(:object_id) { object.id.to_s }

      it_behaves_like "creates the report"
    end
  end

  context "invalid object type" do
    let(:reporter) { FactoryBot.create(:user) }
    let(:object_type) { "invalid_type" }
    let(:object_id) { "1" }

    it_behaves_like "invalid object type"
  end

  context "non-existing object" do
    let(:reporter) { FactoryBot.create(:user) }
    let(:object_type) { "question" }
    let(:object_id) { "999" }

    before do
      allow(Question).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
    end

    it_behaves_like "object not found"
  end
end
