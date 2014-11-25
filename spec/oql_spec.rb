# encoding: UTF-8
require 'oql'

describe 'OQL' do
    describe 'supports the operator' do
        it 'equals' do
            query = 'status == "1"'
            expected = {
                filters: [
                    {
                        condition: {
                            field: 'status',
                            operator: :is_equal,
                            values: [ '1' ]
                        }
                    }
                ]
            }

            expect(OQL.parse(query)).to eql expected
        end
        
        it 'not equal' do
            query = 'status != "1"'
            expected = {
                filters: [
                    {
                        condition: {
                            field: 'status',
                            operator: :not_equal,
                            values: [ '1' ]
                        }
                    }
                ]
            }

            expect(OQL.parse(query)).to eql expected
        end
        
        it 'contains' do
            query = 'name ~ "foo"'
            expected = {
                filters: [
                    {
                        condition: {
                            field: 'name',
                            operator: :contains,
                            values: [ 'foo' ]
                        }
                    }
                ]
            }

            expect(OQL.parse(query)).to eql expected
        end
    end
    
    describe 'supports AND concatenation' do
        it 'once' do
            query = 'status == "1" && type != "2"'
            expected = {
                filters: [
                    {
                        condition: {
                            field: 'status',
                            operator: :is_equal,
                            values: [ '1' ]
                        }
                    },
                    {
                        condition: {
                            field: 'type',
                            operator: :not_equal,
                            values: [ '2' ]
                        }
                    }
                ]
            }

            expect(OQL.parse(query)).to eql expected
        end
        
        it 'repeatedly' do
            query = 'status == "1" && type != "2" && status == "1" && type != "2"'
            result = OQL.parse(query)
            
            expect(result[:filters].size).to eql 4
        end
    end
    
    describe 'supports multi-value syntax' do
        it 'for single values' do
            query = 'status == { "1" }'
            expected = {
                filters: [
                    {
                        condition: {
                            field: 'status',
                            operator: :is_equal,
                            values: [ '1' ]
                        }
                    }
                ]
            }

            expect(OQL.parse(query)).to eql expected
        end
        
        it 'for many values' do
            query = 'status == { "1", "2", "3" }'
            expected = {
                filters: [
                    {
                        condition: {
                            field: 'status',
                            operator: :is_equal,
                            values: [ '1', '2', '3' ]
                        }
                    }
                ]
            }

            expect(OQL.parse(query)).to eql expected
        end
    end
       
    describe 'handles whitespace' do       
        it 'when there is none' do
            query = 'status=="1"&&type!={"2","3"}'

            expect { OQL.parse(query) }.to_not raise_error
        end
        
        it 'when there is too much' do
            query = '   status   ==   "1"   &&   type   !=   {   "2"   ,   "3"   }   '

            expect { OQL.parse(query) }.to_not raise_error
        end
        
        it 'when there are linebreaks' do
            query = '
                    status
                    ==
                    "1"
                    &&
                    type
                    !=
                    {
                    "2"
                    ,
                    "3"
                    }
                    '

            expect { OQL.parse(query) }.to_not raise_error
        end
    end
    
    describe 'fields' do
        it 'are accepted when they contain numbers' do            
            expect{OQL.parse('field12 == "1"')}.to_not raise_error
        end
        
        it 'are accepted when they contain upper and lower case' do            
            expect{OQL.parse('fieldOne == "1"')}.to_not raise_error
        end
        
        it 'are rejected when they start with a number' do            
            expect{OQL.parse('1field == "1"')}.to raise_error
        end
        
        it 'are rejected when they contain non ASCII characters' do            
            expect{OQL.parse('füld == "1"')}.to raise_error
        end
        
        it 'are rejected when they contain underscores' do            
            expect{OQL.parse('field_one == "1"')}.to raise_error
        end
    end
    
    describe 'values' do
        it 'can contain link-ish content' do            
            expect{OQL.parse('status == "/api/v3/statuses/2"')}.to_not raise_error
        end
        
        it 'can contain whitespace and punctuation' do            
            expect{OQL.parse('field == "This is a sentence, with comma."')}.to_not raise_error
        end
        
        it 'can contain umlaute' do            
            expect{OQL.parse('field == "Straßenhäuser"')}.to_not raise_error
        end
        
        it 'can be empty' do            
            result = OQL.parse('field == ""')
            
            expect(result[:filters].first[:condition][:values].first).to eql ''
        end
        
        it 'cannot contain an " alone' do            
            expect{OQL.parse('field == "Foo"Bar"')}.to raise_error
        end
    end
    
    it 'throws an ParseFailed on invalid input' do
        query = 'this is not a query!'
        
        expect{OQL.parse(query)}.to raise_error(ParsingFailed)
    end
end