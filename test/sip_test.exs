defmodule KV.SipTEst do
  use ExUnit.Case

  test "parse sip message" do
    message1 = """
    INVITE
    data1 : This is data 1
    data2
    """

    sipMessage = KV.Sip.parse(message1)

    assert sipMessage[:method] == :invite
    assert sipMessage[:header]["data1"] == "This is data 1"
  end
end
