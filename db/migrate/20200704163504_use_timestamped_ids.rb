# frozen_string_literal: true

require 'securerandom'

# This migration changes the IDs of several tables from serial to a
# timestamped/"snowflake" one.
#
# Instead of "snowflakes" we shall call those IDs Cornflakes or Waspflakes
# instead.
#
# Implementation somewhat lifted from Mastodon.
class UseTimestampedIds < ActiveRecord::Migration[5.2]
  def up
    # PL/pgSQL is just spicy pascal
    # don't @ me
    execute <<~SQL
      CREATE or replace FUNCTION gen_timestamp_id(tblname text) RETURNS bigint AS $$
      DECLARE
        timepart bigint;
        seqpart  bigint;
      BEGIN
        timepart := (date_part('epoch', now()) * 1000)::bigint << 16;
        seqpart := ('x' || substr(md5(tblname ||
                                      '#{SecureRandom.hex(16)}' ||
                                      timepart::text), 1, 4))::bit(16)::bigint;
        RETURN timepart | ((seqpart + nextval(tblname || '_id_seq')) & 65535);
      END;
      $$ LANGUAGE plpgsql VOLATILE;
    SQL

    # we need to migrate related columns to bigints for this to work
    {
      question: %i[answers inboxes],
      answer: %i[comments smiles subscriptions],
      comment: %i[comment_smiles],
      user: %i[announcements answers comment_smiles comments inboxes list_members lists moderation_comments moderation_votes questions reports services smiles subscriptions themes users_roles],

      # polymorphic tables go brrr
      recipient: %i[notifications],
      source: %i[relationships],
      target: %i[notifications relationships reports],
    }.each do |ref, tbls|
      tbls.each do |tbl|
        say "Migrating #{tbl}.#{ref}_id to bigint"
        change_column(tbl, :"#{ref}_id", :bigint)
      end
    end

    %i[questions answers comments smiles comment_smiles users].each do |tbl|
      say "Migrating #{tbl} to use timestamped ids"
      change_column(tbl, :id, :bigint, default: -> { "gen_timestamp_id('#{tbl}'::text)" })
    end
  end
end
