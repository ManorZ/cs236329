function endValue=tradeStock(initialInvestment, price, buy, sell)
transaction_cost = 12.95;
curr_holdings = 0;
curr_cache = initialInvestment;
%fprintf('0) current holdings: %d. current free cache: %d\n', curr_holdings, curr_cache);
for i=1:length(price)
    if isempty(find(buy==i, 1)) && isempty(find(sell==i, 1))
        %fprintf('%d) skip\n', i);
        continue
    elseif ~isempty(find(buy==i, 1))
        % buy as much as possible
        curr_price = price(i);
        available_stocks = floor((curr_cache-transaction_cost)/curr_price);
        if available_stocks > 0
            curr_holdings = curr_holdings + available_stocks;
            curr_cache = curr_cache-transaction_cost-available_stocks*curr_price;
            %fprintf('%d) buy %d stocks at %d$. current holdings: %d. current free cache: %d\n', i, available_stocks, curr_price, curr_holdings, curr_cache);
        else
            %fprintf('%d) unsufficient free cache: %d to buy at %d. skip\n', i, curr_cache, curr_price);
        end
        
    elseif ~isempty(find(sell==i, 1))
        % sell as much as possible (but not in short :))
        % I assume no buy+sell on the same day
        curr_price = price(i);
        potential_gain = curr_holdings * curr_price;
        if (curr_cache + potential_gain > transaction_cost) && (curr_holdings > 0)
            curr_cache = curr_cache - transaction_cost + potential_gain;
            curr_holdings_ = curr_holdings;
            curr_holdings = 0;
            %fprintf('%d) sell %d stocks at %d$. current holdings: %d. current free cache: %d\n', i, curr_holdings_, curr_price, curr_holdings, curr_cache);
        else
            %fprintf('%d) no stocks to sell. skip\n', i);
        end
        
    end
end
i = i+1;
%fprintf('-----\n%d) current holdings: %d. current free cache: %d\n', length(price)+1, curr_holdings, curr_cache);
endValue = curr_cache + curr_holdings * price(length(price));
end