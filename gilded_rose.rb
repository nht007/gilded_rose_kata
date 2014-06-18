require 'delegate'

def update_quality(items)
  items.each do |item|
    item_class = Items.class_mapping[item.name]
    item_class.new(item).update!
  end
end

module Items
  def self.class_mapping
    {
      "NORMAL ITEM"                               => NormalItem,
      "Aged Brie"                                 => AgedBrieItem,
      "Sulfuras, Hand of Ragnaros"                => SulfurasItem,
      "Backstage passes to a TAFKAL80ETC concert" => BackstageItem,
      "Conjured Mana Cake"                        => ConjuredItem
    }
  end

  class ItemDecorator < SimpleDelegator
    MAX_QUALITY = 50

    def age!
      self.sell_in -= 1
    end

    def increase_quality!(amount)
      self.quality += amount
      constrain_quality
    end

    def decrease_quality!(amount)
      self.quality -= amount
      constrain_quality
    end

    def before_sell_date?
      self.sell_in >= 0
    end

    def long_before_sell_date?
      self.sell_in >= 10
    end

    def medium_close_to_sell_date?
      self.sell_in >= 5
    end

    private

    def constrain_quality
      self.quality = 0 if self.quality < 0
      self.quality = MAX_QUALITY if self.quality > MAX_QUALITY
    end
  end

  class NormalItem < ItemDecorator
    def update!
      age!

      if before_sell_date?
        decrease_quality! 1
      else
        decrease_quality! 2
      end
    end
  end

  class AgedBrieItem < ItemDecorator
    def update!
      age!

      if before_sell_date?
        increase_quality! 1
      else
        increase_quality! 2
      end
    end
  end

  class SulfurasItem < ItemDecorator
    def update!
    end
  end

  class BackstageItem < ItemDecorator
    def update!
      age!

      if long_before_sell_date?
        increase_quality! 1
      elsif medium_close_to_sell_date?
        increase_quality! 2
      elsif before_sell_date?
        increase_quality! 3
      else
        self.quality = 0
      end
    end
  end

  class ConjuredItem < ItemDecorator
    def update!
      age!

      if before_sell_date?
        decrease_quality! 2
      else
        decrease_quality! 4
      end
    end
  end
end

# DO NOT CHANGE THINGS BELOW -----------------------------------------

Item = Struct.new(:name, :sell_in, :quality)

# We use the setup in the spec rather than the following for testing.
#
# Items = [
#   Item.new("+5 Dexterity Vest", 10, 20),
#   Item.new("Aged Brie", 2, 0),
#   Item.new("Elixir of the Mongoose", 5, 7),
#   Item.new("Sulfuras, Hand of Ragnaros", 0, 80),
#   Item.new("Backstage passes to a TAFKAL80ETC concert", 15, 20),
#   Item.new("Conjured Mana Cake", 3, 6),
# ]
