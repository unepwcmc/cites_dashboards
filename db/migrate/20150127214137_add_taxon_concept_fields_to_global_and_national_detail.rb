class AddTaxonConceptFieldsToGlobalAndNationalDetail < ActiveRecord::Migration
  def self.up
    add_column :national_detail, :full_name_with_spp, :string
    add_column :national_detail, :genus_name, :string
    add_column :national_detail, :family_name, :string
    add_column :national_detail, :order_name, :string
    add_column :national_detail, :class_name, :string
    add_column :national_detail, :phylum_name, :string
    add_column :national_detail, :kingdom_name, :string
    add_column :global_detail, :full_name_with_spp, :string
    add_column :global_detail, :genus_name, :string
    add_column :global_detail, :family_name, :string
    add_column :global_detail, :order_name, :string
    add_column :global_detail, :class_name, :string
    add_column :global_detail, :phylum_name, :string
    add_column :global_detail, :kingdom_name, :string
  end

  def self.down
    remove_column :national_detail, :full_name_with_spp
    remove_column :national_detail, :genus_name
    remove_column :national_detail, :family_name
    remove_column :national_detail, :order_name
    remove_column :national_detail, :class_name
    remove_column :national_detail, :phylum_name
    remove_column :national_detail, :kingdom_name
    remove_column :global_detail, :full_name_with_spp
    remove_column :global_detail, :genus_name
    remove_column :global_detail, :family_name
    remove_column :global_detail, :order_name
    remove_column :global_detail, :class_name
    remove_column :global_detail, :phylum_name
    remove_column :global_detail, :kingdom_name
  end
end
