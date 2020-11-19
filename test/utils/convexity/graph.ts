import fetch from "node-fetch";

const opynGraphEndpoint =
  "https://api.thegraph.com/subgraphs/name/aparnakr/opyn";

const postQuery = async (query: string, endpoint?: string) => {
  const options = {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify({query}),
  };
  const url = endpoint || opynGraphEndpoint;
  const res = await fetch(url, options);
  return res.json();
};

/**
 * Get vaults for one option
 */
export async function getAllVaultsForOption(
  optionAddress: string
): Promise<
  {
    collateral: string;
    oTokensIssued: string;
    owner: string;
  }[]
> {
  const query = `
  {
    vaults(where: {
      optionsContract: "${optionAddress.toLowerCase()}"
    }) {
      owner
      oTokensIssued,
      collateral,
    }
  }`;
  const response = await postQuery(query);
  const vaults = response.data.vaults;
  return vaults;
}
